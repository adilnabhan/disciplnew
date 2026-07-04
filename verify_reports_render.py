"""
Verification script to test the Advanced Reports & Analytics API on the live Render environment.
"""
import requests
import json
import sys
from datetime import datetime, timedelta

BASE_URL = "https://discipl-backend-u0w9.onrender.com"
TEST_MOBILE = "+919797979797"
MASTER_OTP = "2222"

print("=" * 70)
print(f"VERIFYING REPORTS API ON RENDER: {BASE_URL}")
print("=" * 70)

# Helper function to call endpoints
def call_api(method, path, headers=None, json_data=None, params=None):
    url = f"{BASE_URL}{path}"
    hdrs = headers or {}
    hdrs.setdefault("Content-Type", "application/json")
    hdrs.setdefault("X-Platform", "mentor-app-android")
    try:
        if method.upper() == "GET":
            r = requests.get(url, headers=hdrs, params=params, timeout=60)
        elif method.upper() == "POST":
            r = requests.post(url, headers=hdrs, json=json_data, timeout=60)
        else:
            return None
        return r
    except Exception as e:
        print(f"Exception during {method} {path}: {e}")
        return None

# Step 1: Authenticate Customer (via Guest Login)
print("\n--- STEP 1: Authenticating Customer (Guest) ---")
guest_resp = call_api("POST", "/api/v1/user/login/guest/", json_data={})
if guest_resp is None or guest_resp.status_code not in [200, 201]:
    print(f"Guest login failed: {guest_resp.status_code if guest_resp else 'No response'}")
    sys.exit(1)

guest_data = guest_resp.json()
print(f"Guest login response keys: {list(guest_data.keys())}")
print(f"Full response: {json.dumps(guest_data)[:200]}")
customer_token = guest_data.get("data", {}).get("access_token") or guest_data.get("access_token") or guest_data.get("access")
if not customer_token:
    # Try another common key path
    customer_token = guest_data.get("data", {}).get("access")
print(f"Customer Guest Token: {customer_token[:30] if customer_token else 'None'}...")

customer_headers = {
    "Authorization": f"Bearer {customer_token}",
    "X-Platform": "customer-app-android"
}

# Step 2: Authenticate Mentor
print("\n--- STEP 2: Authenticating Mentor ---")
otp_resp = call_api("POST", "/api/v1/user/send-otp/", json_data={
    "mobile_number": TEST_MOBILE,
    "process": "login",
    "source": "mentor-app-android"
})
if otp_resp is None or otp_resp.status_code not in [200, 201]:
    print(f"Failed to send OTP: {otp_resp.status_code if otp_resp else 'No response'}")
    sys.exit(1)

otp_data = otp_resp.json()
otp_id = otp_data.get("otp_id") or otp_data.get("data", {}).get("otp_id") or otp_data.get("id")

login_resp = call_api("POST", "/api/v1/user/otp/verify/", json_data={
    "otp_id": otp_id,
    "mobile_number": TEST_MOBILE,
    "otp": MASTER_OTP,
    "source": "mentor-app-android",
    "process": otp_data.get("process", "login")
})

mentor_token = None
if login_resp is not None and login_resp.status_code == 200:
    login_data = login_resp.json()
    mentor_token = login_data.get("access") or login_data.get("access_token")
    print(f"Mentor Logged In successfully! Token: {mentor_token[:30]}...")
else:
    print("User does not exist, registering new Mentor...")
    verify_reg_resp = call_api("POST", "/api/v1/user/otp/verification/registration/", json_data={
        "otp_id": otp_id,
        "mobile_number": TEST_MOBILE,
        "otp": MASTER_OTP,
        "process": "registration",
        "source": "mentor-app-android"
    })
    
    onboard_resp = call_api("POST", "/api/v1/user/onboarding/", json_data={
        "otp_id": otp_id,
        "mobile_number": TEST_MOBILE,
        "first_name": "TestMentor",
        "last_name": "RenderTest",
        "user_role": 20, # MENTOR
        "process": "registration",
        "source": "mentor-app-android"
    })
    if onboard_resp is None or onboard_resp.status_code not in [200, 201]:
        print(f"Failed to onboard Mentor: {onboard_resp.text if onboard_resp else ''}")
        sys.exit(1)
        
    mentor_token = onboard_resp.json().get("access") or onboard_resp.json().get("access_token")
    print(f"Mentor Registered successfully! Token: {mentor_token[:30]}...")

mentor_headers = {
    "Authorization": f"Bearer {mentor_token}",
    "X-Platform": "mentor-app-web"
}

# Step 3: Get/Create Organization for Mentor
print("\n--- STEP 3: Getting Organization ID ---")
orgs_resp = call_api("GET", "/api/v1/fitnesscenter/organization/list/", headers=mentor_headers)
org_id = None
if orgs_resp is not None and orgs_resp.status_code == 200:
    orgs = orgs_resp.json()
    org_list = orgs.get("results") if isinstance(orgs, dict) else orgs
    if org_list and len(org_list) > 0:
        org_id = org_list[0].get("id")
        print(f"Found existing organization: ID = {org_id}")

if not org_id:
    import time
    ts = int(time.time())
    print("No organization found, creating a new test organization...")
    create_org_resp = call_api("POST", "/api/v1/fitnesscenter/organization/create/", headers=mentor_headers, json_data={
        "name": f"Reports Gym {ts}",
        "email": f"reports_gym_{ts}@example.com",
        "phone_number": f"+919797979{str(ts)[-3:]}",
        "address": "Reports St",
        "latitude": 12.9716,
        "longitude": 77.5946,
        "categories": [1],
        "description": "Reports test gym"
    })
    if create_org_resp is not None and create_org_resp.status_code in [200, 201]:
        org_id = create_org_resp.json().get("id") or create_org_resp.json().get("data", {}).get("id")
        print(f"Created organization successfully: ID = {org_id}")
    else:
        print(f"Failed to create organization: {create_org_resp.text if create_org_resp else ''}")
        sys.exit(1)

# Step 4: Run reports tests
print("\n--- STEP 4: Testing Reports Endpoints ---")
RESULTS = {"passed": [], "failed": []}

def test_reports_case(name, headers, params, expected_status):
    resp = call_api("GET", "/api/v1/fitnesscenter/reports/", headers=headers, params=params)
    if resp is None:
        print(f"[FAIL] {name} -> No response")
        RESULTS["failed"].append(f"{name} (No response)")
        return None
    
    if resp.status_code == expected_status:
        print(f"[PASS] {name} -> Status: {resp.status_code}")
        RESULTS["passed"].append(name)
        return resp
    else:
        print(f"[FAIL] {name} -> Status: {resp.status_code} (Expected: {expected_status})")
        print(f"       Response: {resp.text[:300]}")
        RESULTS["failed"].append(f"{name} (Status: {resp.status_code}, Expected: {expected_status})")
        return resp

# Test 1: Anonymous Access (401)
test_reports_case("1. Anonymous Access", headers={}, params={"organization_id": org_id}, expected_status=401)

# Test 2: Customer Access (403)
test_reports_case("2. Customer Access", headers=customer_headers, params={"organization_id": org_id}, expected_status=403)

# Test 3: Mentor Access without organization_id (400)
test_reports_case("3. Mentor Access without organization_id", headers=mentor_headers, params={}, expected_status=400)

# Test 4: Mentor Access with invalid organization_id (404)
test_reports_case("4. Mentor Access with invalid organization_id", headers=mentor_headers, params={"organization_id": 999999}, expected_status=404)

# Test 5: Mentor Access with valid organization_id (200)
resp_ok = test_reports_case("5. Mentor Access with valid organization_id", headers=mentor_headers, params={"organization_id": org_id}, expected_status=200)

if resp_ok and resp_ok.status_code == 200:
    data = resp_ok.json()
    print("\n--- Reports JSON Payload Verification ---")
    keys_to_verify = [
        "organization", "filters", "financial_metrics", 
        "client_demographics", "goals_insights", "health_profiles", 
        "attendance_patterns", "trainers_performance"
    ]
    
    all_keys_exist = True
    for key in keys_to_verify:
        if key in data:
            print(f"  [OK] Key exists: '{key}'")
        else:
            print(f"  [MISSING] Key missing: '{key}'")
            all_keys_exist = False
            
    if all_keys_exist:
        print("  [PASS] All expected keys verified in response!")
        RESULTS["passed"].append("Response payload structure validation")
        print("\n--- Detailed Response Payload ---")
        print(json.dumps(data, indent=2))
    else:
        print("  [FAIL] Some keys are missing from response payload!")
        RESULTS["failed"].append("Response payload structure validation")

    # Test 6: Reports with Date Filter (days=30)
    test_reports_case("6. Reports with Date Filter (days=30)", headers=mentor_headers, params={"organization_id": org_id, "days": 30}, expected_status=200)

    # Test 7: Reports with Start/End Date
    today_str = datetime.now().strftime("%Y-%m-%d")
    month_ago_str = (datetime.now() - timedelta(days=30)).strftime("%Y-%m-%d")
    test_reports_case(
        "7. Reports with Date Filter (start_date & end_date)", 
        headers=mentor_headers, 
        params={"organization_id": org_id, "start_date": month_ago_str, "end_date": today_str}, 
        expected_status=200
    )

print("\n" + "=" * 70)
print("VERIFICATION SUMMARY")
print("=" * 70)
print(f"PASSED: {len(RESULTS['passed'])}")
for p in RESULTS["passed"]:
    print(f" - {p}")
print(f"FAILED: {len(RESULTS['failed'])}")
for f in RESULTS["failed"]:
    print(f" - {f}")
print("=" * 70)

sys.exit(0 if len(RESULTS["failed"]) == 0 else 1)
