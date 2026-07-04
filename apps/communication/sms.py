from django.conf import settings

import requests
from apps.utils.mobilenumber import strip_country_code


# OTP_TEMPLATE = '{otp} is your OTP to {process} to Discipl. {signature}'


class BaseSMS:

    _number = None

    def __init__(self, *args, **kwargs):
        pass

    def to(self, number):
        self._number = number

    def get_number(self):
        return strip_country_code(self._number)

    def send_sms(self, message):
        raise NotImplementedError("Subclasses must implement this method")

    def send_sms_by_template(self, template_id, values):
        raise NotImplementedError("Subclasses must implement this method")

    def send_login_otp(self, otp, process='login', signature=None):
        return self.send_sms_by_template(
            template_id=156702, 
            values={
                'otp': otp,
                'process': process,
                'signature': signature, 
            }
        )



class Fast2SMS(BaseSMS):

    def __init__(self, ):
        super().__init__()
        self.api_key = settings.FAST_2_SMS_API_KEY
        self.sender_id = settings.FAST_2_SMS_SENDER_ID

    def send_sms(self, otp_only):
        print(f'[Fast2SMS] Sending to: {self.get_number()}, Message: {otp_only}')
        url = "https://www.fast2sms.com/dev/bulkV2"

        payload = {
            "authorization": self.api_key,
            'sender_id': self.sender_id,
            'message': 156702,
            'language': 'english',
            'route': 'dlt',
            'flash': 0,
            'numbers': int(self.get_number()),
            "variables_values": otp_only
        }
        headers = {
            # 'authorization': self.api_key,
            # 'Content-Type': "application/x-www-form-urlencoded",
            'Cache-Control': "no-cache"
        }
        response = requests.request("GET", url, params=payload, headers=headers)
        print(f'[Fast2SMS] Response: {response.status_code}, {response.text}')
        return response.json()

    def send_sms_by_template(self, template_id, values):
        otp_value = values['otp']
        return self.send_sms(otp_value)

        