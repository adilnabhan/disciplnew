from functools import wraps

from rest_framework import permissions
from rest_framework.exceptions import PermissionDenied

from apps.user.models import User


class user_role_required:
    """
    Usage:
        @method_decorator(user_role_required(User.USER_ROLE_CHOICE, User.USER_ROLE_CHOICE_2), name='dispatch')
        class ExampleView(View):
    """

    def __init__(self, *roles):
        self.roles = roles

    def __call__(self, func):
        @wraps(func)
        def wrapped_view(request, *args, **kwargs):
            if not request.user or not request.user.is_authenticated:
                raise PermissionDenied

            if request.user.user_role not in self.roles:
                raise PermissionDenied

            return func(request, *args, **kwargs)

        return wrapped_view


class UserRolePermission(permissions.BasePermission):
    """
    Custom permission to check if the user has the required role.
    """
    required_roles = ()

    def has_permission(self, request, view):
        # Check if the user is authenticated
        if not request.user or not request.user.is_authenticated:
            return False

        # Check if the user has the required role
        return request.user.user_role in self.required_roles


class UserRolePermissionOrReadOnly(UserRolePermission):
    """
    Custom permission to check if the user has the required role.
    """
    required_roles = ()

    def has_permission(self, request, view):
        # Check if the user is authenticated
        if not request.user or not request.user.is_authenticated:
            return False

        # Check if the user has the required role
        if request.method == 'GET':
            return True
        return request.user.user_role in self.required_roles


class AdminRolePermission(UserRolePermission):
    required_roles = [User.ADMIN_AGENT, User.ADMIN_STAFF, User.ADMIN_ACCOUNTS]


class AdminRolePermissionOrReadOnly(UserRolePermissionOrReadOnly):
    required_roles = [User.ADMIN_AGENT, User.ADMIN_STAFF, User.ADMIN_ACCOUNTS]


class CustomerOnlyPermission(UserRolePermission):
    required_roles = [User.CUSTOMER]


class MentorOnlyPermission(UserRolePermission):
    required_roles = [User.MENTOR, User.MENTOR_TRAINER, User.MENTOR_DIETITIAN]


class MentorPermission(UserRolePermission):
    required_roles = [User.MENTOR, User.MENTOR_ACCOUNTS, User.MENTOR_STAFF, User.MENTOR_TRAINER]
