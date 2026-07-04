"""
Push notification utility using Firebase Cloud Messaging (FCM).
If firebase-admin is not installed or not configured, notifications will
be logged but not sent (non-blocking).
"""

import logging

logger = logging.getLogger(__name__)


def _get_firebase_app():
    """Lazily initialize Firebase app. Returns None if not configured."""
    try:
        import firebase_admin
        from firebase_admin import credentials
        from django.conf import settings
        import os

        # Check if already initialized
        try:
            return firebase_admin.get_app()
        except ValueError:
            pass

        cred_path = getattr(settings, 'FIREBASE_CREDENTIALS_PATH', None)
        if not cred_path or not os.path.exists(cred_path):
            logger.warning(
                "FIREBASE_CREDENTIALS_PATH not set or file not found. "
                "Push notifications are disabled."
            )
            return None

        cred = credentials.Certificate(cred_path)
        return firebase_admin.initialize_app(cred)

    except ImportError:
        logger.warning("firebase-admin not installed. Push notifications disabled.")
        return None
    except Exception as e:
        logger.error(f"Failed to initialize Firebase: {e}")
        return None


def send_push_notification(user, title, body, data=None):
    """
    Send FCM push notification to all active device tokens for a user.
    
    Args:
        user: User instance
        title: Notification title
        body: Notification body text
        data: Optional dict of extra data payload
    
    Returns:
        int: Number of notifications successfully sent
    """
    from apps.communication.models import DeviceToken

    tokens = DeviceToken.objects.filter(
        user=user, is_active=True
    ).values_list('token', flat=True)

    if not tokens:
        logger.info(f"No active device tokens for user {user.id}. Skipping push notification.")
        return 0

    app = _get_firebase_app()
    if not app:
        logger.info(
            f"PUSH_NOTIFICATION (not sent - FCM not configured): "
            f"user={user.id}, title='{title}', body='{body}'"
        )
        return 0

    try:
        from firebase_admin import messaging

        success_count = 0
        failed_tokens = []

        for token in tokens:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body,
                ),
                data=data or {},
                token=token,
            )
            try:
                messaging.send(message)
                success_count += 1
                logger.info(f"Push notification sent to user {user.id} (token: {token[:20]}...)")
            except messaging.UnregisteredError:
                # Token is no longer valid, deactivate it
                failed_tokens.append(token)
                logger.warning(f"Deactivating invalid token for user {user.id}: {token[:20]}...")
            except Exception as e:
                logger.error(f"Failed to send push to user {user.id}: {e}")

        # Deactivate invalid tokens
        if failed_tokens:
            DeviceToken.objects.filter(token__in=failed_tokens).update(is_active=False)

        return success_count

    except Exception as e:
        logger.error(f"Error sending push notification: {e}")
        return 0


def send_push_to_organization_mentor(organization, title, body, data=None):
    """
    Send push notification to the mentor who owns the organization.
    
    Args:
        organization: Organization instance
        title: Notification title
        body: Notification body text
        data: Optional dict of extra data payload
    """
    if organization.mentor and organization.mentor.user:
        return send_push_notification(
            user=organization.mentor.user,
            title=title,
            body=body,
            data=data
        )
    else:
        logger.info(
            f"Organization {organization.id} has no mentor. "
            f"Skipping push notification."
        )
        return 0
