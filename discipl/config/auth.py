# package
JWT_AUTH_HTTPONLY = False
from datetime import timedelta


REST_AUTH = {           # https://dj-rest-auth.readthedocs.io/en/latest/configuration.html
    'USE_JWT': True,
    'JWT_AUTH_RETURN_EXPIRATION': False,
    'JWT_AUTH_HTTPONLY':  False,
    'USER_DETAILS_SERIALIZER': 'apps.user.authentication_apis.serializers.UserProfileResponseSerializer',
}

SIMPLE_JWT = {
    'AUTH_HEADER_TYPES': ('Bearer', 'JWT'),
    'ACCESS_TOKEN_LIFETIME': timedelta(days=2),
    'REFRESH_TOKEN_LIFETIME': timedelta(weeks=4),
    'ROTATE_REFRESH_TOKENS': False,
    'BLACKLIST_AFTER_ROTATION': True,
    'UPDATE_LAST_LOGIN': True,
}