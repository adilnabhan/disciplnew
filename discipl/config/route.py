import os
from discipl.config.base import BASE_DIR, to_bool

ROOT_URLCONF = 'discipl.urls'

ENVIRONMENT = os.getenv('ENVIRONMENT', default='live')
USE_S3 = to_bool('USE_S3')

def get_clean_env(key, default=None):
    val = os.getenv(key, default)
    if val:
        return val.strip().strip('\'"')
    return val

if USE_S3:
    AWS_ACCESS_KEY_ID = get_clean_env('AWS_S3_ACCESS_KEY_ID')
    AWS_SECRET_ACCESS_KEY = get_clean_env('AWS_S3_SECRET_ACCESS_KEY')
    AWS_STORAGE_BUCKET_NAME = get_clean_env('AWS_S3_BUCKET_NAME')
    AWS_S3_REGION_NAME = get_clean_env('AWS_S3_REGION_NAME')
    AWS_S3_ENDPOINT_URL = get_clean_env('AWS_S3_ENDPOINT_URL')
    AWS_S3_FILE_OVERWRITE = get_clean_env('AWS_S3_FILE_OVERWRITE', 'False').lower() == 'true'
    AWS_DEFAULT_ACL = get_clean_env('AWS_DEFAULT_ACL', 'private')  # Changed to private for secure access
    AWS_QUERYSTRING_AUTH = get_clean_env('AWS_QUERYSTRING_AUTH', 'True').lower() == 'true'  # Enable signed URLs
    AWS_S3_OBJECT_PARAMETERS = {'CacheControl': 'max-age=86400'}

    MEDIA_LOCATION = 'media'
    MEDIA_URL = f'{AWS_S3_ENDPOINT_URL}/{AWS_STORAGE_BUCKET_NAME}/{MEDIA_LOCATION}/'

    MEDIA_BACKEND = 'lib.storages.MediaStorage'

    # Static files always served locally via WhiteNoise
    STATIC_URL = '/cdn/'
    STATIC_ROOT = os.path.join(BASE_DIR, 'public/assets/')
    STATIC_BACKEND = 'whitenoise.storage.CompressedManifestStaticFilesStorage'
else:
    MEDIA_URL = '/src/'
    MEDIA_ROOT = os.path.join(BASE_DIR, 'public/media/')
    STATIC_URL = '/cdn/'
    STATIC_ROOT = os.path.join(BASE_DIR, 'public/assets/')
    MEDIA_BACKEND = 'django.core.files.storage.FileSystemStorage'
    STATIC_BACKEND = 'django.contrib.staticfiles.storage.StaticFilesStorage'

STORAGES = {
    'default': {'BACKEND': MEDIA_BACKEND},
    'staticfiles': {'BACKEND': STATIC_BACKEND},
}