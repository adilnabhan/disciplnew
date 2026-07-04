import logging
import hmac
import hashlib
from django.conf import settings
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
from apps.fitnesscenter.models import BankAccountDetails

logger = logging.getLogger(__name__)


@api_view(['POST'])
@permission_classes([AllowAny])  # Razorpay webhook, authenticated via signature
def razorpay_account_webhook(request):
    """
    Webhook endpoint to receive Razorpay account status updates.

    Expected events:
    - account.activated: Account verification successful
    - account.needs_clarification: Verification failed, needs more info
    - account.rejected: Account rejected
    """
    # 1. Verify Razorpay webhook signature
    webhook_signature = request.headers.get('X-Razorpay-Signature')
    webhook_secret = settings.RAZORPAY_WEBHOOK_SECRET

    if not webhook_signature:
        logger.warning("Razorpay webhook received without signature")
        return Response({"error": "No signature provided"}, status=status.HTTP_400_BAD_REQUEST)

    # Create signature hash
    webhook_body = request.body.decode('utf-8')
    expected_signature = hmac.new(
        webhook_secret.encode('utf-8'),
        webhook_body.encode('utf-8'),
        hashlib.sha256
    ).hexdigest()

    if not hmac.compare_digest(webhook_signature, expected_signature):
        logger.error("Invalid Razorpay webhook signature")
        return Response({"error": "Invalid signature"}, status=status.HTTP_401_UNAUTHORIZED)

    # 2. Process webhook payload
    payload = request.data
    event_type = payload.get('event')
    account_data = payload.get('payload', {}).get('account', {}).get('entity', {})
    account_id = account_data.get('id')

    if not account_id:
        logger.warning(f"Razorpay webhook received without account_id: {event_type}")
        return Response({"error": "Missing account_id"}, status=status.HTTP_400_BAD_REQUEST)

    logger.info(f"Razorpay webhook received: {event_type} for account {account_id}")

    # 3. Find corresponding bank account
    try:
        bank_details = BankAccountDetails.objects.get(razorpay_account_id=account_id)
    except BankAccountDetails.DoesNotExist:
        logger.warning(f"Bank details not found for Razorpay account {account_id}")
        return Response({"error": "Account not found"}, status=status.HTTP_404_NOT_FOUND)

    # 4. Update status based on event type
    if event_type == 'account.activated':
        bank_details.razorpay_account_status = BankAccountDetails.ACTIVATED
        bank_details.razorpay_error_details = 'activated'
        logger.info(f"Activated Razorpay account for org {bank_details.organization.id}")

    elif event_type == 'account.needs_clarification':
        bank_details.razorpay_account_status = BankAccountDetails.VERIFICATION_FAILED
        bank_details.razorpay_error_details = 'needs_clarification'
        logger.warning(f"Razorpay account needs clarification for org {bank_details.organization.id}")

    elif event_type == 'account.rejected':
        bank_details.razorpay_account_status = BankAccountDetails.VERIFICATION_FAILED
        bank_details.razorpay_error_details = 'rejected'
        logger.error(f"Razorpay account rejected for org {bank_details.organization.id}")

    else:
        logger.info(f"Unhandled Razorpay event type: {event_type}")
        return Response({"status": "ignored"}, status=status.HTTP_200_OK)

    bank_details.save()

    return Response({"status": "success"}, status=status.HTTP_200_OK)
