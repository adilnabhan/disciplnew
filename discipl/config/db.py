import os
from urllib.parse import urlparse

db_url = os.getenv('DATABASE_URL')

if db_url:
    parsed = urlparse(db_url)
    DATABASES = {
        'default': {
            'ENGINE': 'django.contrib.gis.db.backends.postgis',
            'NAME': parsed.path.lstrip('/'),
            'USER': parsed.username,
            'PASSWORD': parsed.password,
            'HOST': parsed.hostname,
            'PORT': parsed.port or 5432,
            'OPTIONS': {
                'sslmode': 'require',
            }
        }
    }
else:
    host = os.getenv('DB_HOST', 'localhost')
    options = {}
    if host not in ['localhost', '127.0.0.1']:
        options['sslmode'] = 'require'

    DATABASES = {
        'default': {
            'ENGINE': 'django.contrib.gis.db.backends.postgis',
            'NAME': os.getenv('DB_NAME', 'discipl_db'),
            'USER': os.getenv('DB_USER'),
            'PASSWORD': os.getenv('DB_PASSWORD'),
            'HOST': host,
            'PORT': os.getenv('DB_PORT', '5432'),
            'OPTIONS': options
        }
    }

print(DATABASES)