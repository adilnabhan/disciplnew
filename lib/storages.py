from storages.backends.s3boto3 import S3Boto3Storage
import os
import logging
from botocore.exceptions import BotoCoreError, ClientError

logger = logging.getLogger(__name__)


import re

def get_custom_domain():
    custom_domain = os.getenv('STORAGE_PUBLIC_DOMAIN') or None
    endpoint = os.getenv('AWS_S3_ENDPOINT_URL', '')
    if custom_domain and endpoint:
        match = re.search(r'-(00\d)\.', endpoint)
        if match:
            region_num = match.group(1)
            custom_domain = re.sub(r'f00\d', f'f{region_num}', custom_domain)
    return custom_domain


class MediaStorage(S3Boto3Storage):
    location = 'media'
    file_overwrite = False
    default_acl = 'private'
    querystring_auth = True
    querystring_expire = 3600  # URLs valid for 1 hour
    custom_domain = None

    def exists(self, name):
        try:
            return super().exists(name)
        except (BotoCoreError, ClientError) as e:
            logger.error(f"S3 connection error in exists({name}): {e}")
            return False

    def _save(self, name, content):
        try:
            return super()._save(name, content)
        except (BotoCoreError, ClientError) as e:
            logger.error(f"S3 connection error in _save({name}): {e}")
            return name


class StaticStorage(S3Boto3Storage):
    location = 'assets'
    file_overwrite = False
    custom_domain = get_custom_domain()

    def exists(self, name):
        try:
            return super().exists(name)
        except (BotoCoreError, ClientError) as e:
            logger.error(f"S3 connection error in exists({name}): {e}")
            return False

    def _save(self, name, content):
        try:
            return super()._save(name, content)
        except (BotoCoreError, ClientError) as e:
            logger.error(f"S3 connection error in _save({name}): {e}")
            return name