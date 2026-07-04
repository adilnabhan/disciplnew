# middleware.py
from django.http import JsonResponse
from django.utils.deprecation import MiddlewareMixin


class CustomExceptionMiddleware(MiddlewareMixin):
    def process_exception(self, request, exception):
        if isinstance(exception, (ValueError, TypeError)):
            return JsonResponse(
                {'non_field_errors': [str(exception)]},
                status = 400,
            )
        # Handle other exceptions or re-raise
        return None
