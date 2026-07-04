import os
import django

# Initialize Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from django.conf import settings
if 'testserver' not in settings.ALLOWED_HOSTS:
    settings.ALLOWED_HOSTS.append('testserver')

import json
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from apps.utils.token_encoder import jwt_encode
from apps.mentors.models import MentorProfile
from apps.fitnesscenter.models import Organization

User = get_user_model()

def test_profile_update():
    # 1. Setup - Create test mentor user and organization
    mobile = "+917777777777"
    User.objects.filter(mobile_number=mobile).delete()
    Organization.objects.filter(name="Test Sync Gym").delete()
    
    user = User.objects.create(
        username="test_mentor_user",
        mobile_number=mobile,
        first_name="OriginalName",
        last_name="LastName",
        email="mentor_original@example.com",
        user_role=User.MENTOR
    )
    
    # Create mentor profile
    mentor_profile, _ = MentorProfile.objects.get_or_create(user=user)
    
    # Create organization linked to this mentor profile
    org = Organization.objects.create(
        name="Test Sync Gym",
        email="mentor_original@example.com",
        phone_number="+919999999999",
        mentor=mentor_profile,
        active=True
    )
    
    # Also set direct organization on mentor profile
    mentor_profile.organization = org
    mentor_profile.save()
    
    # 2. Generate token
    tokens = jwt_encode(user, platform="mentor-app-web")
    access_token = tokens["access_token"]
    
    # 3. Request
    client = APIClient()
    client.credentials(HTTP_AUTHORIZATION=f'Bearer {access_token}', HTTP_X_PLATFORM='mentor-app-web')
    
    payload = {
        "email": "mentor_new_email@example.com",
        "first_name": "UpdatedMentorName"
    }
    
    response = client.patch('/api/v1/user/profile/update/', payload, format='json')
    
    # 4. Assertions
    print(f"Status Code: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    
    assert response.status_code == 200, f"Expected 200, got {response.status_code}"
    
    user.refresh_from_db()
    assert user.email == "mentor_new_email@example.com", "User email not updated"
    assert user.first_name == "UpdatedMentorName", "User first_name not updated"
    
    # Verify organization email was updated
    org.refresh_from_db()
    assert org.email == "mentor_new_email@example.com", f"Organization email not updated (is still {org.email})"
    
    print("\nSUCCESS: Profile update & organization email sync works successfully!")
    
    # Cleanup
    org.delete()
    user.delete()

if __name__ == "__main__":
    test_profile_update()
