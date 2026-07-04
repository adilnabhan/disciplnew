from rest_framework import exceptions
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError


class SoftJWTAuthentication(JWTAuthentication):
    """
    Same as JWTAuthentication but silently ignores expired/invalid tokens
    instead of raising 401. This allows AllowAny views to work even when
    the client sends an expired token in the Authorization header.
    """
    def authenticate(self, request):
        try:
            return super().authenticate(request)
        except (InvalidToken, TokenError, exceptions.AuthenticationFailed):
            return None
