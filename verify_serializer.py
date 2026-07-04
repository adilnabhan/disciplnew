import os
import django
import sys

# Setup django environment
sys.path.append(os.getcwd())
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from apps.user.models import User, OtpStore
from apps.user.api.serializers import UserRegistrationSerializer
from phonenumber_field.phonenumber import PhoneNumber

def test_onboarding_existing_user():
    mobile = "+919961333048"
    email = "test@gmail.com"
    
    # Check if user exists
    user = User.objects.filter(mobile_number=mobile).first()
    if not user:
        print(f"Creating test user {mobile}")
        user = User.objects.create(
            mobile_number=mobile,
            email=email,
            first_name="Test",
            username=mobile
        )
    else:
        print(f"Found existing user {mobile} with role {user.user_role}")

    # Create a verified OTP for testing
    otp_instance = OtpStore.objects.create(
        mobile_number=mobile,
        otp="2222",
        process="registration",
        source="mentor-app-android",
        verified_at=django.utils.timezone.now()
    )
    print(f"Created verified OTP {otp_instance.id}")

    data = {
        "otp_id": str(otp_instance.id),
        "mobile_number": mobile,
        "first_name": "Updated Name",
        "last_name": "Updated Last",
        "email": email,
        "user_role": "36",
        "process": "registration",
        "source": "mentor-app-android"
    }

    serializer = UserRegistrationSerializer(data=data)
    if serializer.is_valid():
        print("SUCCESS: Serializer is valid for existing user!")
        updated_user = serializer.save()
        print(f"User updated. New role: {updated_user.user_role}")
    else:
        print("FAILED: Serializer errors:")
        print(serializer.errors)

if __name__ == "__main__":
    test_onboarding_existing_user()
