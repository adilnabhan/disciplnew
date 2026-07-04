import os

from dotenv import load_dotenv

load_dotenv('.env')
load_dotenv('.env.override')


SITE_NAME = 'Disciple'

# SMS and OTP
IOS_DEFAULT_NUMBER = '001100110011'
IOS_DEFAULT_OTP = '1100'
OTP_EXPIRY_MINUTES = 20
OTP_RESENT_DELAY_SECONDS = 60

DICIPLE_ISD_CODES = [
    ('IN', '+91')
]

FAST_2_SMS_API_KEY = os.environ.get('FAST_2_SMS_API_KEY')

TRIAL_PERIOD = os.environ.get('TRIAL_PERIOD')

GOOGLE_API_KEY = os.environ.get('GOOGLE_API_KEY')

