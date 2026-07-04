import phonenumbers
import re
from hashlib import sha256


def strip_country_code(phone_number):
    try:
        # Parse the number without specifying a region (handles any country)
        parsed_number = phonenumbers.parse(phone_number)
        
        # Get the national significant number (without country code)
        national_number = phonenumbers.format_number(parsed_number, phonenumbers.PhoneNumberFormat.NATIONAL)
        
        # Remove any possible formatting (spaces, hyphens, etc.)
        stripped_number = ''.join(filter(str.isdigit, national_number))
        return stripped_number
    except phonenumbers.phonenumberutil.NumberParseException:
        return None  # Handle cases where the phone number is invalid
    


def hash_contact_number(number: str):
    """
    Since driver who got ban, may re-register with same number, we store hash of driver mobile number,
    to alert the change of reentry.
    """
    if not number:
        return None
    number = re.sub(r'\D', '', number)
    sha256_hash = sha256(number.encode()).hexdigest()
    return sha256_hash
