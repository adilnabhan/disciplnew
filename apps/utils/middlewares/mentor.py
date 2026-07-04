# middlewares/user_profile_middleware.py

from django.utils.deprecation import MiddlewareMixin
from django.utils.functional import SimpleLazyObject

from apps.mentors.models import MentorProfile
import logging

from apps.user.models import User

logger = logging.getLogger(__name__)


def get_mentor_profile(request):
    if not hasattr(request, '_cached_mentor_profile'):
        try:
            request._cached_mentor_profile = MentorProfile.objects.select_related('user').get(user=request.user)
            logger.info(f"MentorProfile found for {request.user.username}")
        except MentorProfile.DoesNotExist:
            logger.warning(f"MentorProfile not found for {request.user.username}")
            request._cached_mentor_profile = None
    return request._cached_mentor_profile



class MentorMiddleware(MiddlewareMixin):
    def process_request(self, request):
        if not request.user or not request.user.is_authenticated:
            return None

        # Log user role for debugging
        logger.info(f"User role: {request.user.user_role}")

        if getattr(request.user, 'user_role', None) not in User.MENTOR_ROLES:
            return None

        try:
            request.mentor = SimpleLazyObject(lambda: get_mentor_profile(request))
            logger.info(f"Mentor profile for {request.user.username} successfully attached.")
        except Exception as e:
            logger.error(f"Error attaching mentor profile: {str(e)}")
            request.mentor = None
