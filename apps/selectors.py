from phonenumber_field.phonenumber import PhoneNumber

from apps.communication.sms import (
    Fast2SMS,
)


class SMSStrategy:

    def get_provider(self, mobile_number):
        if type(mobile_number) is PhoneNumber:
            mobile_number = f'+{mobile_number.country_code}{mobile_number.national_number}'
        if mobile_number.startswith("+91"):  # Indian numbers start with +91
            provider = Fast2SMS()
            provider.to(mobile_number)
            return provider
        else:
            raise ValueError("Unsupported number format")
