"""
Production API Verification Script for Discipl Backend
Tests ALL endpoints on the live Render deployment: https://discipl-backend.onrender.com
"""
import os
os.environ['PYTHONIOENCODING'] = 'utf-8'

import requests
import json
import sys

BASE_URL = "https://discipl-backend.onrender.com"
RESULTS = {"passed": [], "failed": []}

HEADERS = {"X-Platform": "customer-app-android", "Content-Type": "application/json"}
MENTOR_HEADERS = {"X-Platform": "mentor-app-android", "Content-Type": "application/json"}
TRAINER_HEADERS = {"X-Platform": "vendor-app-android", "Content-Type": "application/json"}


def test(method, path, name, headers=None, json_data=None, expected=None):
    if expected is None:
        expected = [200]
    url = f"{BASE_URL}{path}"
    hdrs = headers or HEADERS.copy()

    try:
        if method == "GET":
            r = requests.get(url, headers=hdrs, timeout=30)
        elif method == "POST":
            r = requests.post(url, headers=hdrs, json=json_data, timeout=30)
        elif method == "PUT":
            r = requests.put(url, headers=hdrs, json=json_data, timeout=30)
        elif method == "PATCH":
            r = requests.patch(url, headers=hdrs, json=json_data, timeout=30)
        elif method == "DELETE":
            r = requests.delete(url, headers=hdrs, timeout=30)
        else:
            return None

        ok = r.status_code in expected
        body = ""
        try:
            body = json.dumps(r.json(), indent=2)[:300]
        except Exception:
            body = r.text[:300]

        if ok:
            RESULTS["passed"].append(f"[PASS] {name} -> {r.status_code}")
        else:
            RESULTS["failed"].append(
                f"[FAIL] {name} -> {r.status_code} (expected {expected})\n   {body}"
            )

        # Flag any 500 errors as CRITICAL
        if r.status_code == 500:
            RESULTS["failed"].append(f"[CRITICAL 500] {name} -> Server Error!\n   {body}")

        return r
    except requests.exceptions.ConnectionError:
        RESULTS["failed"].append(f"[FAIL] {name} -> CONNECTION REFUSED")
        return None
    except requests.exceptions.Timeout:
        RESULTS["failed"].append(f"[FAIL] {name} -> TIMEOUT (>30s)")
        return None
    except Exception as e:
        RESULTS["failed"].append(f"[FAIL] {name} -> ERROR: {str(e)}")
        return None


def section(title):
    print(f"\n{'='*65}")
    print(f"  {title}")
    print(f"{'='*65}")


# ═══════════════════════════════════════════════════════════════
# 1. HEALTH & INFRA
# ═══════════════════════════════════════════════════════════════
section("1. HEALTH & INFRASTRUCTURE")
test("GET", "/health-check/", "Health Check", headers={})

# ═══════════════════════════════════════════════════════════════
# 2. USER / AUTH APIs
# ═══════════════════════════════════════════════════════════════
section("2. USER / AUTH APIs")

test("POST", "/api/v1/user/send-otp/", "Send OTP (missing fields)",
     json_data={}, expected=[400])

test("POST", "/api/v1/user/send-otp/", "Send OTP (valid number)",
     json_data={"mobile_number": "+919999999999"}, expected=[200, 201, 400, 429])

test("POST", "/api/v1/user/otp/verify/", "OTP Login Verify (bad data)",
     json_data={"mobile_number": "+919999999999", "otp": "0000"}, expected=[400])

test("POST", "/api/v1/user/otp/verification/registration/", "OTP Reg Verify (bad data)",
     json_data={"mobile_number": "+919999999999", "otp": "0000"}, expected=[400])

test("POST", "/api/v1/user/onboarding/", "Onboarding (bad data)",
     json_data={"first_name": "Test"}, expected=[400])

test("POST", "/api/v1/user/login/", "Login (bad creds)",
     json_data={"username": "invalid", "password": "invalid"}, expected=[400, 401])

test("POST", "/api/v1/user/login/guest/", "Guest Login",
     json_data={}, expected=[200, 201])

test("POST", "/api/v1/user/create-superuser/", "Create Superuser",
     headers={}, expected=[200, 201, 400, 403])


# ═══════════════════════════════════════════════════════════════
# 3. CUSTOMER APIs (Public - No Auth)
# ═══════════════════════════════════════════════════════════════
section("3. CUSTOMER APIs (Public)")

test("GET", "/api/v1/customer/customer-homepage/", "Customer Homepage")
test("GET", "/api/v1/customer/constant-choices/", "Constant Choices")
test("GET", "/api/v1/customer/nearest/fitnesscenter/", "Nearest Fitness Centers")
test("GET", "/api/v1/customer/nearest/fitnesscenter/?lat=12.9716&lon=77.5946",
     "Nearest FC with Coordinates")
test("GET", "/api/v1/customer/nearest/fitnesscenter/?lat=12.9716&lon=77.5946&radius_km=5",
     "Nearest FC with Radius 5km")

# ═══════════════════════════════════════════════════════════════
# 4. CUSTOMER APIs (Auth Required - should get 401)
# ═══════════════════════════════════════════════════════════════
section("4. CUSTOMER APIs (Auth Enforcement)")

test("GET", "/api/v1/customer/common/injuries/", "Injuries (no auth)", expected=[401])
test("GET", "/api/v1/customer/common/medical-conditions/", "Medical Conditions (no auth)", expected=[401])
test("GET", "/api/v1/customer/payment-history/", "Payment History (no auth)", expected=[401])
test("GET", "/api/v1/customer/membership-org/", "Membership Orgs (no auth)", expected=[401])
test("GET", "/api/v1/customer/workout-log/", "Workout Log (no auth)", expected=[401])
test("POST", "/api/v1/customer/manage/create/", "Customer Create (no auth)",
     json_data={}, expected=[401])
test("POST", "/api/v1/customer/membership-request/create/", "Membership Req Create (no auth)",
     json_data={}, expected=[401])
test("GET", "/api/v1/customer/membership-request/list/", "Membership Req List (no auth)",
     expected=[401])


# ═══════════════════════════════════════════════════════════════
# 5. FITNESS CENTER APIs
# ═══════════════════════════════════════════════════════════════
section("5. FITNESS CENTER APIs")

test("GET", "/api/v1/fitnesscenter/categories/", "Categories (public)")
test("GET", "/api/v1/fitnesscenter/amenities/", "Amenities (auth required)", expected=[401])
test("GET", "/api/v1/fitnesscenter/home/", "Org Home (no auth)", expected=[401])
test("GET", "/api/v1/fitnesscenter/customers/", "Customer List (no auth)", expected=[401])
test("GET", "/api/v1/fitnesscenter/trainers/", "Trainers List (no auth)", expected=[401])
test("POST", "/api/v1/fitnesscenter/organization/create/", "Org Create (no auth)",
     json_data={}, expected=[401])
test("GET", "/api/v1/fitnesscenter/organization/list/", "Org List (no auth)", expected=[401])
test("GET", "/api/v1/fitnesscenter/membership-plans/", "Membership Plans (no auth)", expected=[401])
test("GET", "/api/v1/fitnesscenter/bank-details/", "Bank Details (no auth)", expected=[401])
test("GET", "/api/v1/fitnesscenter/expiring-memberships/", "Expiring Memberships (no auth)", expected=[401])
test("GET", "/api/v1/fitnesscenter/membership-requests/", "Gym Membership Reqs (no auth)", expected=[401])
test("GET", "/api/v1/fitnesscenter/trainer-requests/", "Trainer Reqs (no auth)", expected=[401])
test("POST", "/api/v1/fitnesscenter/coupon/validate/", "Coupon Validate (no auth)",
     json_data={}, expected=[401])
test("GET", "/api/v1/fitnesscenter/customer_renewals/", "Customer Renewals (no auth)", expected=[401])
test("GET", "/api/v1/fitnesscenter/customer-payments/", "Customer Payments (no auth)", expected=[401])

# Direct Gym APIs (no auth required)
test("GET", "/api/v1/fitnesscenter/gym/list/", "Gym List (public)")
test("POST", "/api/v1/fitnesscenter/gym/create/", "Gym Create (public)",
     json_data={"name": "Test Gym"}, expected=[200, 201, 400])


# ═══════════════════════════════════════════════════════════════
# 6. TRAINER APIs
# ═══════════════════════════════════════════════════════════════
section("6. TRAINER APIs")

# Auth enforcement
test("GET", "/api/v1/trainer/trainers/experience/", "Trainer Experience (no auth)",
     headers=TRAINER_HEADERS, expected=[401])
test("GET", "/api/v1/trainer/muscle-groups/", "Muscle Groups (no auth)",
     headers=TRAINER_HEADERS, expected=[401])
test("GET", "/api/v1/trainer/equipment/", "Equipment (no auth)",
     headers=TRAINER_HEADERS, expected=[401])
test("GET", "/api/v1/trainer/exercise-types/", "Exercise Types (no auth)",
     headers=TRAINER_HEADERS, expected=[401])
test("GET", "/api/v1/trainer/exercises/", "Exercises (no auth)",
     headers=TRAINER_HEADERS, expected=[401])
test("GET", "/api/v1/trainer/workout-groups/", "Workout Groups (no auth)",
     headers=TRAINER_HEADERS, expected=[401])
test("GET", "/api/v1/trainer/workout-plans/", "Workout Plans (no auth)",
     headers=TRAINER_HEADERS, expected=[401])
test("GET", "/api/v1/trainer/customers/", "Trainer Customers (no auth)",
     headers=TRAINER_HEADERS, expected=[401])
test("GET", "/api/v1/trainer/dashboard/", "Trainer Dashboard (no auth)",
     headers=TRAINER_HEADERS, expected=[401])
test("GET", "/api/v1/trainer/subscription-plans/", "Subscription Plans (no auth)",
     headers=TRAINER_HEADERS, expected=[401])
test("POST", "/api/v1/trainer/link-requests/", "Link Request (no auth)",
     headers=TRAINER_HEADERS, json_data={}, expected=[401])

# Trainer onboarding URLs
test("GET", "/api/v1/trainer/trainers/", "Trainer List (no auth)",
     headers=TRAINER_HEADERS, expected=[401])
test("GET", "/api/v1/trainer/specializations/", "Specializations (no auth)",
     headers=TRAINER_HEADERS, expected=[401])
test("GET", "/api/v1/trainer/languages/", "Languages (no auth)",
     headers=TRAINER_HEADERS, expected=[401])
test("GET", "/api/v1/trainer/plans/", "Trainer Plans (no auth)",
     headers=TRAINER_HEADERS, expected=[401])


# ═══════════════════════════════════════════════════════════════
# 7. COMMUNICATION APIs
# ═══════════════════════════════════════════════════════════════
section("7. COMMUNICATION APIs")

test("POST", "/api/v1/communication/device-token/register/", "Device Token Reg (no auth)",
     json_data={"token": "test", "platform": "customer-app-android"}, expected=[401])
test("POST", "/api/v1/communication/device-token/delete/", "Device Token Del (no auth)",
     json_data={"token": "test"}, expected=[401])


# ═══════════════════════════════════════════════════════════════
# 8. SUBSCRIPTION APIs
# ═══════════════════════════════════════════════════════════════
section("8. SUBSCRIPTION APIs")

test("GET", "/api/v1/subscription/discipl-subscription-plans/", "Discipl Plans (no auth)",
     expected=[401])
test("POST", "/api/v1/subscription/create-order/", "Create Order (no auth)",
     json_data={}, expected=[401])
test("POST", "/api/v1/subscription/trainer/create-order/", "Trainer Order (no auth)",
     json_data={}, expected=[401])
test("GET", "/api/v1/subscription/payment/status/", "Payment Status (no auth)",
     expected=[401])
test("POST", "/api/v1/subscription/customer/create-order/", "Customer Order (no auth)",
     json_data={}, expected=[401])


# ═══════════════════════════════════════════════════════════════
# 9. MENTOR APIs
# ═══════════════════════════════════════════════════════════════
section("9. MENTOR APIs")

test("GET", "/api/v1/mentor/trainers/", "Mentor Trainers (no auth)",
     headers=MENTOR_HEADERS, expected=[401])


# ═══════════════════════════════════════════════════════════════
# 10. AUTHENTICATED FLOW (using Guest Login token)
# ═══════════════════════════════════════════════════════════════
section("10. AUTHENTICATED FLOW (Guest Login)")

guest_resp = test("POST", "/api/v1/user/login/guest/", "Guest Login for Token",
                  json_data={}, expected=[200, 201])

if guest_resp and guest_resp.status_code in [200, 201]:
    try:
        guest_data = guest_resp.json()
        guest_token = guest_data.get("access") or guest_data.get("data", {}).get("access_token") or guest_data.get("access_token")
        if guest_token:
            print(f"  Got guest token: {guest_token[:30]}...")
            auth_hdrs = {
                "X-Platform": "customer-app-android",
                "Authorization": f"Bearer {guest_token}",
                "Content-Type": "application/json"
            }

            test("GET", "/api/v1/customer/customer-homepage/", "Homepage (authed)",
                 headers=auth_hdrs)
            test("GET", "/api/v1/customer/constant-choices/", "Choices (authed)",
                 headers=auth_hdrs)
            test("GET", "/api/v1/customer/nearest/fitnesscenter/", "Nearest FC (authed)",
                 headers=auth_hdrs)
            test("GET", "/api/v1/fitnesscenter/categories/", "Categories (authed)",
                 headers=auth_hdrs)
            test("GET", "/api/v1/fitnesscenter/gym/list/", "Gym List (authed)",
                 headers=auth_hdrs)
        else:
            print(f"  Could not extract token from: {json.dumps(guest_data)[:200]}")
    except Exception as e:
        print(f"  Error parsing guest response: {e}")
else:
    print("  Skipping authenticated tests (no guest token)")


# ═══════════════════════════════════════════════════════════════
# RESULTS
# ═══════════════════════════════════════════════════════════════
section("FINAL RESULTS")

print(f"\nPASSED: {len(RESULTS['passed'])}")
for r in RESULTS["passed"]:
    print(f"   {r}")

if RESULTS["failed"]:
    print(f"\nFAILED: {len(RESULTS['failed'])}")
    for r in RESULTS["failed"]:
        print(f"   {r}")

total = len(RESULTS["passed"]) + len(RESULTS["failed"])
pass_rate = (len(RESULTS['passed']) / total * 100) if total else 0
print(f"\n{'='*65}")
print(f"  TOTAL: {total} | PASS: {len(RESULTS['passed'])} | FAIL: {len(RESULTS['failed'])} | Rate: {pass_rate:.0f}%")
print(f"{'='*65}")

# Save results
with open("discipl_production_api_results.txt", "w") as f:
    f.write(f"Production API Verification - {BASE_URL}\n{'='*50}\n\n")
    f.write(f"PASSED: {len(RESULTS['passed'])}\n")
    for r in RESULTS["passed"]:
        f.write(f"  {r}\n")
    f.write(f"\nFAILED: {len(RESULTS['failed'])}\n")
    for r in RESULTS["failed"]:
        f.write(f"  {r}\n")
    f.write(f"\nTOTAL: {total} | PASS: {len(RESULTS['passed'])} | FAIL: {len(RESULTS['failed'])} | Rate: {pass_rate:.0f}%\n")

sys.exit(0 if len(RESULTS["failed"]) == 0 else 1)
