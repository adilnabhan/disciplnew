"""
Script to verify promotional banners and advanced reports APIs.
Uses Django ORM directly to set up necessary test data and test endpoints.
"""
import os
import sys
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

# Monkeypatch Razorpay integration directly in the loaded models namespace to prevent API calls in verify script
import apps.fitnesscenter.models
apps.fitnesscenter.models.create_razorpay_base_plan = lambda plan: (True, "")

import requests
import json

BASE_URL = "http://127.0.0.1:8000"
RESULTS = {"passed": [], "failed": []}

def test_endpoint(method, path, name, headers=None, data=None, json_data=None, expected_statuses=None):
    if expected_statuses is None:
        expected_statuses = [200, 201]
    
    url = f"{BASE_URL}{path}"
    hdrs = headers or {}
    hdrs["X-Platform"] = "mentor-app-android"
    
    try:
        if method.upper() == "GET":
            resp = requests.get(url, headers=hdrs, timeout=10)
        elif method.upper() == "POST":
            resp = requests.post(url, headers=hdrs, data=data, json=json_data, timeout=10)
        elif method.upper() == "PUT":
            resp = requests.put(url, headers=hdrs, data=data, json=json_data, timeout=10)
        elif method.upper() == "DELETE":
            resp = requests.delete(url, headers=hdrs, timeout=10)
        else:
            return None

        status_ok = resp.status_code in expected_statuses
        
        body_preview = ""
        try:
            body_preview = json.dumps(resp.json(), indent=2)[:500]
        except Exception:
            body_preview = resp.text[:500] if resp.text else "(empty)"

        if status_ok:
            RESULTS["passed"].append(f"[PASS] {name} -> {resp.status_code}")
            print(f"PASS: {name} (Status: {resp.status_code})")
        else:
            RESULTS["failed"].append(
                f"[FAIL] {name} -> {resp.status_code} (expected {expected_statuses})\n"
                f"   Response: {body_preview}"
            )
            print(f"FAIL: {name} (Status: {resp.status_code}, Expected: {expected_statuses})\nResponse: {body_preview}")
        
        return resp
    except Exception as e:
        RESULTS["failed"].append(f"[FAIL] {name} -> ERROR: {str(e)}")
        print(f"FAIL: {name} -> ERROR: {str(e)}")
        return None

# ─────────────────────────────────────────────────────────────────
# Setup necessary test data using Django ORM
# ─────────────────────────────────────────────────────────────────
from apps.user.models import User
from apps.fitnesscenter.models import Organization
from apps.mentors.models import MentorProfile
from apps.customers.models import Customer
from apps.utils.token_encoder import jwt_encode

print("=" * 60)
print("  Setting up Test Data in Django DB")
print("=" * 60)

# 1. Create/get Mentor user & Profile
mentor_user, created = User.objects.get_or_create(
    mobile_number="+919876549999",
    defaults={
        "username": "test_mentor_rep",
        "email": "mentor_rep@discipl.com",
        "first_name": "TestMentor",
        "last_name": "Reports",
        "user_role": User.MENTOR,
        "is_active": True,
    }
)
if created:
    mentor_user.set_password("test123")
    mentor_user.save()

mentor_profile, created = MentorProfile.objects.get_or_create(
    user=mentor_user,
)

# 2. Create/get Organization and link to Mentor
org, created = Organization.objects.get_or_create(
    name="Test verification Gym",
    defaults={
        "mentor": mentor_profile,
        "email": "verif_gym@discipl.com",
        "phone_number": "+919876549991",
    }
)
if not mentor_profile.organizations.filter(id=org.id).exists():
    mentor_profile.organizations.add(org)

# 3. Create/get Customer user & Profile
customer_user, created = User.objects.get_or_create(
    mobile_number="+919876548888",
    defaults={
        "username": "test_cust_rep",
        "email": "cust_rep@discipl.com",
        "first_name": "TestCustomer",
        "last_name": "Reports",
        "user_role": User.CUSTOMER,
        "is_active": True,
    }
)
if created:
    customer_user.set_password("test123")
    customer_user.save()

customer, created = Customer.objects.get_or_create(
    user=customer_user,
    defaults={
        "organization": org,
        "fitness_level": "beginner",
        "weight_goal": "lose_weight",
    }
)
# Signal may auto-create Customer with organization=None; force-update always
if not customer.organization or customer.organization != org:
    customer.organization = org
    customer.fitness_level = customer.fitness_level or "beginner"
    customer.weight_goal = customer.weight_goal or "lose_weight"
    customer.save()

# 3.5. Seed rich financial, trainer, and workout data for advanced reports
from apps.fitnesscenter.models import MembershipPlan
from apps.customers.models import CustomerMembership, CustomerMembershipTransaction
from apps.trainer.models import Trainer, OrganizationTrainerLink, WorkoutPlan, CustomerWorkoutPlan

# Create trainer
trainer_user, created = User.objects.get_or_create(
    mobile_number="+919876547777",
    defaults={
        "username": "test_trainer_rep",
        "email": "trainer_rep@discipl.com",
        "first_name": "TestTrainer",
        "last_name": "Reports",
        "user_role": 20, # User.MENTOR role
        "is_active": True,
    }
)
if created:
    trainer_user.set_password("test123")
    trainer_user.save()

trainer, created = Trainer.objects.get_or_create(
    user=trainer_user,
    defaults={
        "first_name": "TestTrainer",
        "last_name": "Reports",
        "experience_years": 3,
        "user_type": "trainer"
    }
)

# Link trainer to gym org
link, created = OrganizationTrainerLink.objects.get_or_create(
    trainer=trainer,
    organization=org,
    defaults={"status": "approved"}
)
if not created and link.status != "approved":
    link.status = "approved"
    link.save()

# Create Gym Membership Plan
plan, created = MembershipPlan.objects.get_or_create(
    organization=org,
    package_type="Monthly Plan",
    defaults={
        "name": "Super Monthly Pack",
        "actual_price": 2000.00,
        "offer_price": 1800.00,
        "duration_days": 30,
        "is_active": True
    }
)

# Create Customer Membership
membership, created = CustomerMembership.objects.get_or_create(
    customer=customer,
    membership=plan,
    defaults={
        "amount": 1800.00,
        "status": "Active",
        "payment_status": "completed",
        "is_active": True
    }
)

# Create Customer Transaction
transaction, created = CustomerMembershipTransaction.objects.get_or_create(
    customer=customer,
    membership=plan,
    subscription=membership,
    amount=1800.00,
    defaults={
        "status": "Successful"
    }
)

# Create Workout Plan
workout_plan, created = WorkoutPlan.objects.get_or_create(
    trainer=trainer,
    organization=org,
    plan_name="Massive Gains Plan",
    defaults={
        "status": True,
        "total_weeks": 4
    }
)

# Assign Workout Plan to Customer
customer_workout_plan, created = CustomerWorkoutPlan.objects.get_or_create(
    customer=customer,
    trainer=trainer,
    plan=workout_plan,
    defaults={
        "status": "active"
    }
)

# 4. Generate JWT tokens
mentor_token = jwt_encode(mentor_user, "mentor-app-android")['access_token']
customer_token = jwt_encode(customer_user, "customer-app-android")['access_token']

mentor_headers = {"Authorization": f"Bearer {mentor_token}"}
customer_headers = {"Authorization": f"Bearer {customer_token}"}
anon_headers = {}

print("Test data setup complete. Starting API Tests...")
print("=" * 60)

# ─────────────────────────────────────────────────────────────────
# Reports API Tests
# ─────────────────────────────────────────────────────────────────
print("\n--- Testing Advanced Reports & Analytics ---")

# 1. Anonymous Access (Expected: 401)
test_endpoint("GET", "/api/v1/fitnesscenter/reports/", "Reports: Anonymous Access", 
              headers=anon_headers, expected_statuses=[401])

# 2. Customer Access (Expected: 403)
test_endpoint("GET", f"/api/v1/fitnesscenter/reports/?organization_id={org.id}", "Reports: Customer Access", 
              headers=customer_headers, expected_statuses=[403])

# 3. Mentor Access without org_id (Expected: 400)
test_endpoint("GET", "/api/v1/fitnesscenter/reports/", "Reports: Mentor Access (No org_id)", 
              headers=mentor_headers, expected_statuses=[400])

# 4. Mentor Access with invalid org_id (Expected: 404)
test_endpoint("GET", "/api/v1/fitnesscenter/reports/?organization_id=99999", "Reports: Mentor Access (Invalid org_id)", 
              headers=mentor_headers, expected_statuses=[404])

# 5. Mentor Access with valid org_id (Expected: 200)
test_endpoint("GET", f"/api/v1/fitnesscenter/reports/?organization_id={org.id}", "Reports: Mentor Access (Valid org_id)", 
              headers=mentor_headers, expected_statuses=[200])

# ─────────────────────────────────────────────────────────────────
# Banners API Tests
# ─────────────────────────────────────────────────────────────────
print("\n--- Testing Promotional Banners ---")

# 1. Anonymous GET Banners (Expected: 200)
test_endpoint("GET", "/api/v1/fitnesscenter/banners/", "Banners: Anonymous List", 
              headers=anon_headers, expected_statuses=[200])

# 2. Customer POST Banner (Expected: 403)
test_endpoint("POST", "/api/v1/fitnesscenter/banners/", "Banners: Customer Create", 
              headers=customer_headers, 
              json_data={"title": "Promo 1", "banner_type": "promotional"}, 
              expected_statuses=[403])

# 3. Mentor POST Banner (Expected: 201)
banner_payload = {
    "title": "Summer Special Offer",
    "banner_type": "promotional",
    "external_link": "https://discipl.com/summer-promo",
    "is_active": True
}
create_banner_resp = test_endpoint("POST", "/api/v1/fitnesscenter/banners/", "Banners: Mentor Create", 
                                   headers=mentor_headers, 
                                   json_data=banner_payload, 
                                   expected_statuses=[201])

if create_banner_resp and create_banner_resp.status_code == 201:
    banner_id = create_banner_resp.json().get("id")
    print(f"Created Banner ID: {banner_id}")
    
    # 4. Retrieve Banners List (Expected to include newly created banner)
    test_endpoint("GET", f"/api/v1/fitnesscenter/banners/?organization_id={org.id}", "Banners: Retrieve Gym Banners", 
                  headers=anon_headers, expected_statuses=[200])

    # 5. Mentor Update Banner (Expected: 200)
    update_payload = {"title": "Updated Summer Special Offer"}
    test_endpoint("PUT", f"/api/v1/fitnesscenter/banners/{banner_id}/", "Banners: Mentor Update Banner", 
                  headers=mentor_headers, 
                  json_data=update_payload, 
                  expected_statuses=[200])

    # 6. Mentor Delete Banner (Expected: 200)
    test_endpoint("DELETE", f"/api/v1/fitnesscenter/banners/{banner_id}/", "Banners: Mentor Delete Banner", 
                  headers=mentor_headers, expected_statuses=[200])

print("\n" + "=" * 60)
print("  VERIFICATION SUMMARY")
print("=" * 60)
print(f"PASSED: {len(RESULTS['passed'])}")
print(f"FAILED: {len(RESULTS['failed'])}")
print("=" * 60)
sys.exit(0 if len(RESULTS["failed"]) == 0 else 1)
