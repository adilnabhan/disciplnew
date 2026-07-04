REST_FRAMEWORK = {
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'apps.utils.authentication.SoftJWTAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_PAGINATION_CLASS': 'apps.utils.pagination.CustomPagination',
    'DEFAULT_FILTER_BACKENDS': [
        'django_filters.rest_framework.DjangoFilterBackend',
    ],
    'PAGE_SIZE': 10,
}

SPECTACULAR_SETTINGS = {
    'TITLE': 'Discipl Backoffice API Documentation',
    'DESCRIPTION': 'The Core Backend for Discipl',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
}
