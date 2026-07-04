from django.conf import settings
from django.http import JsonResponse
from django.utils.deprecation import MiddlewareMixin

from apps.user.models import OtpStore, User


def verify_required_headers(request):
    """
    Verify the request by checking all the required headers are present
    """

    required_headers = ['X-Platform']
    missing_headers = [header for header in required_headers if header not in request.headers]

    if missing_headers:
        return JsonResponse({
                    "error": "Missing required headers",
                    "missing_headers": missing_headers
                }, status=400)

    return None


def validate_headers(request):

    """
    Validate the required headers
    """

    invalid_headers = []

    if request.platform.lower() not in [choice[0] for choice in User.PLATFORM_CHOICES]:
        # return error if the platform header is not valid
        invalid_headers.append('X-Platform')

    if invalid_headers:
        return JsonResponse({
            "error": "Invalid headers",
            "invalid_headers": invalid_headers
        }, status=400)

    return None


class HeadersMiddleWare(MiddlewareMixin):
    def process_request(self, request):
        print("Middleware triggered!")
        # List of paths to skip the middleware
        skip_paths = [
            '/api/schema/redoc',
            '/api/schema/swagger-ui',
            '/api/redoc',
            '/api/schema',
            '/api/v1/user/create-superuser/',
            '/api/v1/subscription/webhook/',
            '/api/v1/subscription/razorpay/checkout/',
            '/api/v1/fitnesscenter/gym/',
        ]

        # Skip middleware for paths not starting with '/api' or specific paths to skip
        if not request.path.startswith('/api') or any(request.path.startswith(path) for path in skip_paths):
            return None

        response = verify_required_headers(request)
        # since each stage depend on another we need to return own response as the function return
        if response:
            return response

        platform = request.META['HTTP_X_PLATFORM']
        print(f"Platform header: {platform}")

        request.platform = platform
        response = validate_headers(request)
        if response:
            return response

