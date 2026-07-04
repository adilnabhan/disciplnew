"""
Authenticated API verification - tests endpoints that require JWT tokens.
Uses Django ORM directly to create a test user and generate a valid token.
"""
import os
import sys
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

import requests
import json

BASE_URL = "http://127.0.0.1:8000"
RESULTS = {"passed": [], "failed": []}

def test_endpoint(method, path, name, headers=None, data=None, json_data=None,
                  expected_statuses=None):
    if expected_statuses is None:
        expected_statuses = [200, 201]
    
    url = f"{BASE_URL}{path}"
    hdrs = headers or {}
    hdrs["X-Platform"] = "customer-app-android"
    
    try:
        if method.upper() == "GET":
            resp = requests.get(url, headers=hdrs, timeout=10)
        elif method.upper() == "POST":
            resp = requests.post(url, headers=hdrs, data=data, json=json_data, timeout=10)
        elif method.upper() == "PUT":
            resp = requests.put(url, headers=hdrs, data=data, json=json_data, timeout=10)
        elif method.upper() == "PATCH":
            resp = requests.patch(url, headers=hdrs, data=data, json=json_data, timeout=10)
        elif method.upper() == "DELETE":
            resp = requests.delete(url, headers=hdrs, timeout=10)
        else:
            return None

        status_ok = resp.status_code in expected_statuses
        
        if status_ok:
            RESULTS["passed"].append(f"[PASS] {name} -> {resp.status_code}")
        else:
            body_preview = resp.text[:300] if resp.text else "(empty)"
            RESULTS["failed"].append(
                f"[FAIL] {name} -> {resp.status_code} (expected {expected_statuses})\n"
                f"   Response: {body_preview}"
            )
        
        return resp
    except Exception as e:
        RESULTS["failed"].append(f"[FAIL] {name} -> ERROR: {str(e)}")
        return None


def print_section(title):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")


# ─────────────────────────────────────────────────────────────────
# Create test users using Django ORM
# ─────────────────────────────────────────────────────────────────
from apps.user.models import User
from apps.utils.token_encoder import jwt_encode

print_section("SETTING UP TEST USERS")

# Create/get a Customer test user
customer_user, created = User.objects.get_or_create(
    mobile_number="+919876543210",
    defaults={
        "first_name": "TestCustomer",
        "last_name": "API",
        "user_role": User.CUSTOMER,
        "is_active": True,
    }
)
if created:
    customer_user.set_password("test123")
    customer_user.save()
    print(f"Created customer user: {customer_user.id}")
else:
    print(f"Using existing customer user: {customer_user.id}")

token_data = jwt_encode(customer_user, "customer-app-android")
customer_token = token_data['access_token']
print(f"Customer token generated (first 30 chars): {customer_token[:30]}...")

# Create/get a Mentor test user
mentor_user, created = User.objects.get_or_create(
    mobile_number="+919876543211",
    defaults={
        "first_name": "TestMentor",
        "last_name": "API",
        "user_role": User.MENTOR,
        "is_active": True,
    }
)
if created:
    mentor_user.set_password("test123")
    mentor_user.save()
    print(f"Created mentor user: {mentor_user.id}")
else:
    print(f"Using existing mentor user: {mentor_user.id}")

token_data = jwt_encode(mentor_user, "mentor-app-android")
mentor_token = token_data['access_token']
print(f"Mentor token generated (first 30 chars): {mentor_token[:30]}...")

# Create/get a Trainer test user
trainer_user, created = User.objects.get_or_create(
    mobile_number="+919876543212",
    defaults={
        "first_name": "TestTrainer",
        "last_name": "API",
        "user_role": User.MENTOR_TRAINER,
        "is_active": True,
    }
)
if created:
    trainer_user.set_password("test123")
    trainer_user.save()
    print(f"Created trainer user: {trainer_user.id}")
else:
    print(f"Using existing trainer user: {trainer_user.id}")

token_data = jwt_encode(trainer_user, "vendor-app-android")
trainer_token = token_data['access_token']
print(f"Trainer token generated (first 30 chars): {trainer_token[:30]}...")


# ─────────────────────────────────────────────────────────────────
# AUTHENTICATED CUSTOMER TESTS
# ─────────────────────────────────────────────────────────────────
print_section("CUSTOMER APIs (Authenticated)")

customer_headers = {
    "Authorization": f"Bearer {customer_token}",
    "X-Platform": "customer-app-android"
}

test_endpoint("GET", "/api/v1/customer/customer-homepage/", "Customer Homepage",
              headers=customer_headers, expected_statuses=[200])

test_endpoint("GET", "/api/v1/customer/constant-choices/", "Choices API",
              headers=customer_headers, expected_statuses=[200])

test_endpoint("GET", "/api/v1/customer/nearest/fitnesscenter/", "Nearest Fitness Centers",
              headers=customer_headers, expected_statuses=[200])

test_endpoint("GET", "/api/v1/customer/nearest/fitnesscenter/?lat=12.9716&lon=77.5946", 
              "Nearest Fitness Centers with coords",
              headers=customer_headers, expected_statuses=[200])

test_endpoint("GET", "/api/v1/customer/common/injuries/", "Get Injuries",
              headers=customer_headers, expected_statuses=[200])

test_endpoint("GET", "/api/v1/customer/common/medical-conditions/", "Get Medical Conditions",
              headers=customer_headers, expected_statuses=[200])

test_endpoint("GET", "/api/v1/customer/payment-history/", "Payment History",
              headers=customer_headers, expected_statuses=[200, 400, 403, 404])

test_endpoint("GET", "/api/v1/customer/membership-org/", "Membership Org List",
              headers=customer_headers, expected_statuses=[200, 400, 403, 404])

test_endpoint("GET", "/api/v1/customer/membership-request/list/", "Membership Request List",
              headers=customer_headers, expected_statuses=[200, 400, 403, 404])

test_endpoint("GET", "/api/v1/customer/payment-detail-history/", "Payment Detail History",
              headers=customer_headers, expected_statuses=[200, 400, 403, 404])


# ─────────────────────────────────────────────────────────────────
# AUTHENTICATED MENTOR/FITNESS CENTER TESTS
# ─────────────────────────────────────────────────────────────────
print_section("FITNESSCENTER APIs (Authenticated as Mentor)")

mentor_headers = {
    "Authorization": f"Bearer {mentor_token}",
    "X-Platform": "mentor-app-android"
}

test_endpoint("GET", "/api/v1/fitnesscenter/categories/", "Get Categories",
              headers=mentor_headers, expected_statuses=[200])

test_endpoint("GET", "/api/v1/fitnesscenter/amenities/", "Get Amenities",
              headers=mentor_headers, expected_statuses=[200])

test_endpoint("GET", "/api/v1/fitnesscenter/home/", "Organization Home (no org_id)",
              headers=mentor_headers, expected_statuses=[200, 400, 403])

test_endpoint("GET", "/api/v1/fitnesscenter/organization/list/", "Organization List",
              headers=mentor_headers, expected_statuses=[200, 403, 404])

test_endpoint("GET", "/api/v1/fitnesscenter/membership-plans/", "Membership Plans List",
              headers=mentor_headers, expected_statuses=[200, 403])

test_endpoint("GET", "/api/v1/fitnesscenter/gym/list/", "Gym List (public)",
              headers=mentor_headers, expected_statuses=[200])


# ─────────────────────────────────────────────────────────────────
# AUTHENTICATED TRAINER TESTS
# ─────────────────────────────────────────────────────────────────
print_section("TRAINER APIs (Authenticated)")

trainer_headers = {
    "Authorization": f"Bearer {trainer_token}",
    "X-Platform": "vendor-app-android"
}

test_endpoint("GET", "/api/v1/trainer/muscle-groups/", "Muscle Groups List",
              headers=trainer_headers, expected_statuses=[200])

test_endpoint("GET", "/api/v1/trainer/equipment/", "Equipment List",
              headers=trainer_headers, expected_statuses=[200])

test_endpoint("GET", "/api/v1/trainer/exercise-types/", "Exercise Types List",
              headers=trainer_headers, expected_statuses=[200])

test_endpoint("GET", "/api/v1/trainer/exercises/", "Exercises List",
              headers=trainer_headers, expected_statuses=[200])

test_endpoint("GET", "/api/v1/trainer/workout-groups/", "Workout Groups List",
              headers=trainer_headers, expected_statuses=[200, 404])

test_endpoint("GET", "/api/v1/trainer/workout-plans/", "Workout Plans List",
              headers=trainer_headers, expected_statuses=[200, 404])

test_endpoint("GET", "/api/v1/trainer/customers/", "Trainer Customers List",
              headers=trainer_headers, expected_statuses=[200, 404])

test_endpoint("GET", "/api/v1/trainer/dashboard/", "Trainer Dashboard",
              headers=trainer_headers, expected_statuses=[200, 400, 404])

test_endpoint("GET", "/api/v1/trainer/subscription-plans/", "Trainer Subscription Plans",
              headers=trainer_headers, expected_statuses=[200])


# ─────────────────────────────────────────────────────────────────
# COMMUNICATION APIs
# ─────────────────────────────────────────────────────────────────
print_section("COMMUNICATION APIs (Authenticated)")

test_endpoint("POST", "/api/v1/communication/device-token/register/", 
              "Device Token Register",
              headers=customer_headers,
              json_data={"token": "test-fcm-token-12345", "platform": "customer-app-android"},
              expected_statuses=[200, 201])

test_endpoint("POST", "/api/v1/communication/device-token/delete/", 
              "Device Token Delete",
              headers=customer_headers,
              json_data={"token": "test-fcm-token-12345"},
              expected_statuses=[200, 204, 404])


# ─────────────────────────────────────────────────────────────────
# SUBSCRIPTION APIs
# ─────────────────────────────────────────────────────────────────
print_section("SUBSCRIPTION APIs (Authenticated)")

test_endpoint("GET", "/api/v1/subscription/discipl-subscription-plans/", 
              "Discipl Subscription Plans",
              headers=mentor_headers, expected_statuses=[200])


# ─────────────────────────────────────────────────────────────────
# RESULTS SUMMARY
# ─────────────────────────────────────────────────────────────────
print_section("RESULTS SUMMARY")

print(f"\nPASSED: {len(RESULTS['passed'])}")
for r in RESULTS["passed"]:
    print(f"   {r}")

if RESULTS["failed"]:
    print(f"\nFAILED: {len(RESULTS['failed'])}")
    for r in RESULTS["failed"]:
        print(f"   {r}")

total = len(RESULTS["passed"]) + len(RESULTS["failed"])
print(f"\n{'='*60}")
print(f"  TOTAL: {total} | PASS: {len(RESULTS['passed'])} | FAIL: {len(RESULTS['failed'])}")
print(f"{'='*60}")

# Save results
with open("api_auth_results.txt", "w") as f:
    f.write(f"Authenticated API Results\n{'='*40}\n\n")
    f.write(f"PASSED: {len(RESULTS['passed'])}\n")
    for r in RESULTS["passed"]:
        f.write(f"  {r}\n")
    f.write(f"\nFAILED: {len(RESULTS['failed'])}\n")
    for r in RESULTS["failed"]:
        f.write(f"  {r}\n")
    f.write(f"\nTOTAL: {total} | PASS: {len(RESULTS['passed'])} | FAIL: {len(RESULTS['failed'])}\n")

sys.exit(0 if len(RESULTS["failed"]) == 0 else 1)
