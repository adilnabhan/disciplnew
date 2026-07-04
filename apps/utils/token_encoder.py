import uuid
from datetime import timedelta
from django.conf import settings
from django.utils import timezone
from rest_framework_simplejwt.tokens import RefreshToken

def jwt_encode(user, platform=None):
    """
    Generate JWT tokens for the user, optionally associated with a specific platform.
    Returns access and refresh tokens.
    """
    refresh = RefreshToken.for_user(user)
    
    refresh['user_id'] = str(user.id)
    refresh['role'] = user.user_role
    if getattr(user, "is_guest", False):
        refresh['is_guest'] = True

        # Convert PhoneNumber → string safely
        refresh['username'] = (
            str(user.username) if user.username else None
        )
        refresh['mobile_number'] = (
            user.mobile_number.as_international
            if user.mobile_number else None
        )
    else:
        refresh['username'] = str(user.username) if user.username else None
        refresh['mobile_number'] = str(user.mobile_number) if user.mobile_number else None

    if platform:
        refresh['platform'] = platform

        if platform not in user.platforms:
            user.add_platform(platform)

    access_token = refresh.access_token

    return {
        'access_token': str(access_token),
        'refresh_token': str(refresh),
    }