"""
Comprehensive API Verification Script for Discipl Backend
Tests ALL endpoints across Customer, Trainer, Fitnesscenter, Communication,
Subscription, User, and Mentor modules.
"""
import os
os.environ['PYTHONIOENCODING'] = 'utf-8'

import requests
import json
import sys

BASE_URL = "http://127.0.0.1:8000"
RESULTS = {"passed": [], "failed": [], "skipped": []}

# ─────────────────────────────────────────────────────────────────
# Test utility
# ─────────────────────────────────────────────────────────────────
def test_endpoint(method, path, name, headers=None, data=None, json_data=None,
                  expected_statuses=None, need_auth=False, auth_token=None):
    """Test a single API endpoint and record the result."""
    if expected_statuses is None:
        expected_statuses = [200, 201]
    
    url = f"{BASE_URL}{path}"
    hdrs = headers or {}
    hdrs["X-Platform"] = "customer-app-android"
    
    if need_auth and auth_token:
        hdrs["Authorization"] = f"Bearer {auth_token}"
    elif need_auth and not auth_token:
        # Without auth, expect 401/403
        expected_statuses = [401, 403]
    
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
            RESULTS["skipped"].append(f"{name}: Unknown method {method}")
            return None

        status_ok = resp.status_code in expected_statuses
        
        if status_ok:
            RESULTS["passed"].append(f"[PASS] {name} -> {resp.status_code}")
        else:
            body_preview = resp.text[:200] if resp.text else "(empty)"
            RESULTS["failed"].append(
                f"[FAIL] {name} -> {resp.status_code} (expected {expected_statuses})\n"
                f"   Response: {body_preview}"
            )
        
        return resp
    except requests.exceptions.ConnectionError:
        RESULTS["failed"].append(f"[FAIL] {name} -> CONNECTION REFUSED (server not running?)")
        return None
    except Exception as e:
        RESULTS["failed"].append(f"[FAIL] {name} -> ERROR: {str(e)}")
        return None


def print_section(title):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")


# ─────────────────────────────────────────────────────────────────
# 1. HEALTH CHECK
# ─────────────────────────────────────────────────────────────────
print_section("HEALTH CHECK")
test_endpoint("GET", "/health-check/", "Health Check", expected_statuses=[200])
test_endpoint("GET", "/api/schema/redoc/", "Redoc API Docs", 
              headers={}, expected_statuses=[200, 301, 302, 404])


# ─────────────────────────────────────────────────────────────────
# 2. USER / AUTH APIs  
# ─────────────────────────────────────────────────────────────────
print_section("USER / AUTH APIs")

# OTP Generate
resp = test_endpoint("POST", "/api/v1/user/send-otp/", "Send OTP",
                     json_data={"mobile_number": "+919999999999"},
                     expected_statuses=[200, 201, 400, 429])

# OTP Validate (will fail without real OTP, but should not 500)
test_endpoint("POST", "/api/v1/user/otp/verify/", "OTP Login Verify (expected fail)",
              json_data={"otp_id": 99999, "mobile_number": "+919999999999", "otp": "1234"},
              expected_statuses=[200, 400, 404])

# Registration OTP verify
test_endpoint("POST", "/api/v1/user/otp/verification/registration/", "OTP Registration Verify (expected fail)",
              json_data={"otp_id": 99999, "mobile_number": "+919999999999", "otp": "1234"},
              expected_statuses=[200, 400, 404])

# Register (expected to fail without valid OTP, should not 500)
test_endpoint("POST", "/api/v1/user/onboarding/", "Onboarding/Register (expected fail)",
              json_data={
                  "otp_id": 99999,
                  "mobile_number": "+919999999999",
                  "first_name": "Test",
                  "user_role": 10
              },
              expected_statuses=[200, 400, 404])

# Login (expected to fail, should not 500)
test_endpoint("POST", "/api/v1/user/login/", "Login (expected fail)",
              json_data={"username": "test", "password": "test"},
              expected_statuses=[200, 400, 404])

# Guest login
test_endpoint("POST", "/api/v1/user/login/guest/", "Guest Login",
              json_data={},
              expected_statuses=[200, 201, 400])

# Create superuser (idempotent)
test_endpoint("POST", "/api/v1/user/create-superuser/", "Create Superuser",
              expected_statuses=[200, 201, 400, 403, 500])


# ─────────────────────────────────────────────────────────────────
# 3. CUSTOMER APIs (No Auth - should get 401/403)
# ─────────────────────────────────────────────────────────────────
print_section("CUSTOMER APIs (Auth Check)")

test_endpoint("GET", "/api/v1/customer/customer-homepage/", "Customer Homepage (public)",
              expected_statuses=[200])

test_endpoint("GET", "/api/v1/customer/constant-choices/", "Choices API (public)",
              expected_statuses=[200])

test_endpoint("GET", "/api/v1/customer/common/injuries/", "Get Injuries (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/customer/common/medical-conditions/", "Get Medical Conditions (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/customer/nearest/fitnesscenter/", "Nearest Fitness Centers (public)",
              expected_statuses=[200])

test_endpoint("GET", "/api/v1/customer/nearest/fitnesscenter/?lat=12.9716&lon=77.5946", 
              "Nearest Fitness Centers with coords (public)",
              expected_statuses=[200])

test_endpoint("GET", "/api/v1/customer/payment-history/", "Payment History (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/customer/membership-org/", "Membership Org List (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("POST", "/api/v1/customer/manage/create/", "Customer Create (auth required)",
              json_data={}, need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/customer/workout-log/", "Customer Workout Log (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("POST", "/api/v1/customer/membership-request/create/", 
              "Membership Request Create (auth required)",
              json_data={}, need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/customer/membership-request/list/", 
              "Membership Request List (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/customer/payment-detail-history/", 
              "Payment Detail History (auth required)",
              need_auth=True, expected_statuses=[401, 403])


# ─────────────────────────────────────────────────────────────────
# 4. FITNESS CENTER APIs
# ─────────────────────────────────────────────────────────────────
print_section("FITNESS CENTER APIs")

test_endpoint("GET", "/api/v1/fitnesscenter/categories/", "Get Categories",
              expected_statuses=[200])

test_endpoint("GET", "/api/v1/fitnesscenter/amenities/", "Get Amenities (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/fitnesscenter/home/", "Organization Home (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/fitnesscenter/customers/", "Customer List (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/fitnesscenter/trainers/", "Trainers List (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("POST", "/api/v1/fitnesscenter/organization/create/", 
              "Organization Create (auth required)",
              json_data={}, need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/fitnesscenter/organization/list/", 
              "Organization List (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/fitnesscenter/membership-plans/", 
              "Membership Plans List (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/fitnesscenter/bank-details/", 
              "Bank Details List (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/fitnesscenter/expiring-memberships/", 
              "Expiring Memberships (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/fitnesscenter/membership-requests/", 
              "Gym Membership Requests (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/fitnesscenter/trainer-requests/", 
              "Trainer Requests List (auth required)",
              need_auth=True, expected_statuses=[401, 403])

# Direct Gym APIs (no auth required)
test_endpoint("GET", "/api/v1/fitnesscenter/gym/list/", "Gym List (public)",
              expected_statuses=[200])

test_endpoint("POST", "/api/v1/fitnesscenter/coupon/validate/", 
              "Coupon Validation (auth required)",
              json_data={}, need_auth=True, expected_statuses=[400, 401, 403])


# ─────────────────────────────────────────────────────────────────
# 5. TRAINER APIs (Onboarding)
# ─────────────────────────────────────────────────────────────────
print_section("TRAINER APIs (Onboarding)")

test_endpoint("GET", "/api/v1/trainer/trainers/basic-details/", 
              "Trainer Basic Details GET (auth required)",
              need_auth=True, expected_statuses=[401, 403, 404])

test_endpoint("GET", "/api/v1/trainer/specializations/", 
              "Specialization List",
              expected_statuses=[200, 401, 403])

test_endpoint("GET", "/api/v1/trainer/languages/", 
              "Language List",
              expected_statuses=[200, 401, 403])

test_endpoint("GET", "/api/v1/trainer/trainers/", 
              "Trainer List",
              expected_statuses=[200, 401, 403])

test_endpoint("GET", "/api/v1/trainer/plans/", 
              "Trainer Plans List",
              expected_statuses=[200, 401, 403])


# ─────────────────────────────────────────────────────────────────
# 6. TRAINER APIs (Workout Management)
# ─────────────────────────────────────────────────────────────────
print_section("TRAINER APIs (Workout Management)")

test_endpoint("GET", "/api/v1/trainer/muscle-groups/", 
              "Muscle Groups List",
              expected_statuses=[200, 401, 403])

test_endpoint("GET", "/api/v1/trainer/equipment/", 
              "Equipment List",
              expected_statuses=[200, 401, 403])

test_endpoint("GET", "/api/v1/trainer/exercise-types/", 
              "Exercise Types List",
              expected_statuses=[200, 401, 403])

test_endpoint("GET", "/api/v1/trainer/exercises/", 
              "Exercises List (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/trainer/workout-groups/", 
              "Workout Groups List (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/trainer/workout-plans/", 
              "Workout Plans List (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/trainer/customers/", 
              "Trainer Customers List (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/trainer/dashboard/", 
              "Trainer Dashboard (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/trainer/subscription-plans/", 
              "Trainer Subscription Plans (auth required)",
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("POST", "/api/v1/trainer/link-requests/", 
              "Trainer Link Request (auth required)",
              json_data={}, need_auth=True, expected_statuses=[401, 403])


# ─────────────────────────────────────────────────────────────────
# 7. COMMUNICATION APIs
# ─────────────────────────────────────────────────────────────────
print_section("COMMUNICATION APIs")

test_endpoint("POST", "/api/v1/communication/device-token/register/", 
              "Device Token Register (auth required)",
              json_data={"token": "test-token", "platform": "android"},
              need_auth=True, expected_statuses=[401, 403])

test_endpoint("POST", "/api/v1/communication/device-token/delete/", 
              "Device Token Delete (auth required)",
              json_data={"token": "test-token"},
              need_auth=True, expected_statuses=[401, 403])


# ─────────────────────────────────────────────────────────────────
# 8. SUBSCRIPTION APIs
# ─────────────────────────────────────────────────────────────────
print_section("SUBSCRIPTION APIs")

test_endpoint("GET", "/api/v1/subscription/discipl-subscription-plans/", 
              "Discipl Subscription Plans",
              expected_statuses=[200, 401, 403])

test_endpoint("POST", "/api/v1/subscription/create-order/", 
              "Create Razorpay Order (auth required)",
              json_data={}, need_auth=True, expected_statuses=[401, 403])

test_endpoint("POST", "/api/v1/subscription/customer/create-order/", 
              "Create Customer Order (auth required)",
              json_data={}, need_auth=True, expected_statuses=[401, 403])

test_endpoint("GET", "/api/v1/subscription/payment/status/", 
              "Check Payment Status (auth required)",
              need_auth=True, expected_statuses=[401, 403])


# ─────────────────────────────────────────────────────────────────
# 9. MENTOR APIs
# ─────────────────────────────────────────────────────────────────
print_section("MENTOR APIs")

test_endpoint("GET", "/api/v1/mentor/trainers/", 
              "Mentor Trainers List (auth required)",
              need_auth=True, expected_statuses=[401, 403])


# ─────────────────────────────────────────────────────────────────
# 10. URL RESOLUTION (check no 404 on routes)
# ─────────────────────────────────────────────────────────────────
print_section("URL RESOLUTION (No 404 on valid routes)")

# Verify no 500 errors on any route
critical_paths = [
    "/api/v1/customer/customer-homepage/",
    "/api/v1/customer/constant-choices/",
    "/api/v1/customer/nearest/fitnesscenter/",
    "/api/v1/fitnesscenter/categories/",
    "/api/v1/fitnesscenter/gym/list/",
    "/health-check/",
]

for path in critical_paths:
    resp = test_endpoint("GET", path, f"No-500 Check: {path}", 
                         expected_statuses=[200, 301, 302])
    if resp and resp.status_code == 500:
        RESULTS["failed"].append(f"[CRITICAL] {path} returned 500!")


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

if RESULTS["skipped"]:
    print(f"\nSKIPPED: {len(RESULTS['skipped'])}")
    for r in RESULTS["skipped"]:
        print(f"   {r}")

total = len(RESULTS["passed"]) + len(RESULTS["failed"]) + len(RESULTS["skipped"])
print(f"\n{'='*60}")
print(f"  TOTAL: {total} | PASS: {len(RESULTS['passed'])} | FAIL: {len(RESULTS['failed'])} | SKIP: {len(RESULTS['skipped'])}")
print(f"{'='*60}")

# Save results to file
with open("api_verification_results.txt", "w") as f:
    f.write(f"API Verification Results\n{'='*40}\n\n")
    f.write(f"PASSED: {len(RESULTS['passed'])}\n")
    for r in RESULTS["passed"]:
        f.write(f"  {r}\n")
    f.write(f"\nFAILED: {len(RESULTS['failed'])}\n")
    for r in RESULTS["failed"]:
        f.write(f"  {r}\n")
    f.write(f"\nTOTAL: {total} | PASS: {len(RESULTS['passed'])} | FAIL: {len(RESULTS['failed'])}\n")

sys.exit(0 if len(RESULTS["failed"]) == 0 else 1)
