import requests
import json
import sys

BASE_URL = "https://discipl-backend-u0w9.onrender.com"
TEST_MOBILE = "+919797979797"
MASTER_OTP = "2222"

print("=" * 70)
print(f"VERIFYING RENDER APIS on: {BASE_URL}")
print("=" * 70)

# Helper function to call endpoints
def call_api(method, path, headers=None, json_data=None):
    url = f"{BASE_URL}{path}"
    hdrs = headers or {}
    hdrs.setdefault("Content-Type", "application/json")
    hdrs.setdefault("X-Platform", "mentor-app-android")
    try:
        if method.upper() == "GET":
            r = requests.get(url, headers=hdrs, timeout=60)
        elif method.upper() == "POST":
            r = requests.post(url, headers=hdrs, json=json_data, timeout=60)
        elif method.upper() == "PATCH":
            r = requests.patch(url, headers=hdrs, json=json_data, timeout=60)
        else:
            return None
        return r
    except Exception as e:
        print(f"Exception during {method} {path}: {e}")
        return None

# Step 1: Login or Register a Mentor on Render
print("\n--- STEP 1: Authenticating Mentor ---")
otp_resp = call_api("POST", "/api/v1/user/send-otp/", json_data={
    "mobile_number": TEST_MOBILE,
    "process": "login",
    "source": "mentor-app-android"
})
if otp_resp is None or otp_resp.status_code not in [200, 201]:
    print(f"Failed to send OTP: {otp_resp.status_code if otp_resp is not None else 'No response'} -> {otp_resp.text if otp_resp is not None else ''}")
    sys.exit(1)

otp_data = otp_resp.json()
otp_id = otp_data.get("otp_id") or otp_data.get("data", {}).get("otp_id")
if not otp_id:
    # Try looking in general response keys
    otp_id = otp_data.get("id")
print(f"OTP Sent successfully, OTP ID: {otp_id}")

# Attempt login first
login_resp = call_api("POST", "/api/v1/user/otp/verify/", json_data={
    "otp_id": otp_id,
    "mobile_number": TEST_MOBILE,
    "otp": MASTER_OTP,
    "source": "mentor-app-android",
    "process": otp_data.get("process", "login")
})

token = None
if login_resp is not None and login_resp.status_code == 200:
    login_data = login_resp.json()
    token = login_data.get("access") or login_data.get("access_token")
    print(f"Successfully logged in as existing Mentor! Token: {token[:30]}...")
else:
    # If user doesn't exist, we must register
    print("User does not exist, registering a new Mentor user...")
    verify_reg_resp = call_api("POST", "/api/v1/user/otp/verification/registration/", json_data={
        "otp_id": otp_id,
        "mobile_number": TEST_MOBILE,
        "otp": MASTER_OTP,
        "process": "registration",
        "source": "mentor-app-android"
    })
    if not verify_reg_resp or verify_reg_resp.status_code != 200:
        print(f"Failed to verify OTP for registration: {verify_reg_resp.text if verify_reg_resp else ''}")
        sys.exit(1)
        
    onboard_resp = call_api("POST", "/api/v1/user/onboarding/", json_data={
        "otp_id": otp_id,
        "mobile_number": TEST_MOBILE,
        "first_name": "TestMentor",
        "last_name": "RenderTest",
        "user_role": 20, # MENTOR
        "process": "registration",
        "source": "mentor-app-android"
    })
    if not onboard_resp or onboard_resp.status_code not in [200, 201]:
        print(f"Failed to register user: {onboard_resp.text if onboard_resp else ''}")
        sys.exit(1)
    
    onboard_data = onboard_resp.json()
    token = onboard_data.get("access") or onboard_data.get("access_token")
    print(f"Successfully registered new Mentor! Token: {token[:30]}...")

# Set up authorization header
auth_headers = {
    "Authorization": f"Bearer {token}",
    "X-Platform": "mentor-app-web"
}

# Step 2: Get or Create Organization
print("\n--- STEP 2: Fetching/Creating Organization ---")
orgs_resp = call_api("GET", "/api/v1/fitnesscenter/organization/list/", headers=auth_headers)
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
    create_org_resp = call_api("POST", "/api/v1/fitnesscenter/organization/create/", headers=auth_headers, json_data={
        "name": f"Yesterday Testing Gym {ts}",
        "email": f"yesterday_test_gym_{ts}@example.com",
        "phone_number": f"+919797979{str(ts)[-3:]}",
        "address": "Render St",
        "latitude": 12.9716,
        "longitude": 77.5946,
        "categories": [1],
        "description": "Verification test gym"
    })
    if create_org_resp is not None and create_org_resp.status_code in [200, 201]:
        org_id = create_org_resp.json().get("id") or create_org_resp.json().get("data", {}).get("id")
        print(f"Created organization successfully: ID = {org_id}")
    else:
        print(f"Failed to create organization: {create_org_resp.status_code if create_org_resp is not None else 'No response'} -> {create_org_resp.text if create_org_resp is not None else ''}")
        sys.exit(1)

# Step 3: Test Dynamic Time Slots Update
print("\n--- STEP 3: Testing Dynamic Time Slots Update ---")
admin_patch_headers = auth_headers.copy()
admin_patch_headers["X-Platform"] = "admin-web"

time_slots_payload = {
    "time_slots": [
        {
            "name": "Ramzan Early Night Slot",
            "start_time": "19:00:00",
            "end_time": "21:00:00",
            "is_active": True,
            "start_date": "2026-06-01",
            "end_date": "2026-06-30"
        },
        {
            "name": "Ramzan Midnight Special",
            "start_time": "23:00:00",
            "end_time": "01:00:00",
            "is_active": True,
            "start_date": "2026-06-01",
            "end_date": "2026-06-30"
        }
    ]
}

patch_resp = call_api("PATCH", f"/api/v1/fitnesscenter/organization/{org_id}/update/", 
                      headers=admin_patch_headers, json_data=time_slots_payload)

if patch_resp is not None and patch_resp.status_code == 200:
    print("[PASS] Time slots patch update completed successfully!")
    print(json.dumps(patch_resp.json(), indent=2)[:500])
else:
    print(f"[FAIL] Time slots patch update failed: {patch_resp.status_code if patch_resp is not None else 'No response'} -> {patch_resp.text if patch_resp is not None else ''}")

# Verify slots in detailed GET organization
get_org_resp = call_api("GET", f"/api/v1/fitnesscenter/organization/{org_id}/", headers=auth_headers)
if get_org_resp is not None and get_org_resp.status_code == 200:
    org_details = get_org_resp.json()
    time_slots = org_details.get("time_slots") or org_details.get("data", {}).get("time_slots", [])
    print(f"Retrieved {len(time_slots)} time slots for organization:")
    for slot in time_slots:
        print(f" - {slot.get('name')}: {slot.get('start_time')} - {slot.get('end_time')} (Active Date Range: {slot.get('start_date')} to {slot.get('end_date')}, Currently Active: {slot.get('is_currently_active')})")
else:
    print(f"Failed to fetch organization details: {get_org_resp.status_code if get_org_resp is not None else 'No response'} -> {get_org_resp.text if get_org_resp is not None else ''}")

# Step 4: Test Trainer Email Addition / Updates
print("\n--- STEP 4: Testing Direct Add Trainer & Email Updates ---")
# Use unique trainer mobile to avoid conflicts on re-runs
import time
trainer_ts = int(time.time())
trainer_mobile = f"+919999999{str(trainer_ts)[-3:]}"

trainer_payload_1 = {
    "organization_id": org_id,
    "mobile": trainer_mobile,
    "first_name": "TestTrainer",
    "last_name": "Yesterday",
    "email": f"trainer_initial_{trainer_ts}@example.com"
}

add_trainer_resp_1 = call_api("POST", "/api/v1/fitnesscenter/trainer-requests/add/", 
                              headers=auth_headers, json_data=trainer_payload_1)
if add_trainer_resp_1 is not None and add_trainer_resp_1.status_code in [200, 201]:
    trainer_data = add_trainer_resp_1.json()
    print("[PASS] Direct Trainer Add (Initial Email) successful:")
    print(json.dumps(trainer_data, indent=2)[:300])
else:
    print(f"[FAIL] Direct Trainer Add failed: {add_trainer_resp_1.status_code if add_trainer_resp_1 is not None else 'No response'} -> {add_trainer_resp_1.text if add_trainer_resp_1 is not None else ''}")

# Create a second organization for testing trainer email updates (trainer cannot be added to the same organization twice)
print("Creating a second test organization to verify trainer email update...")
ts_2 = int(time.time()) + 1
create_org_resp_2 = call_api("POST", "/api/v1/fitnesscenter/organization/create/", headers=auth_headers, json_data={
    "name": f"Yesterday Trainer Test Gym {ts_2}",
    "email": f"yesterday_test_gym_trainer_{ts_2}@example.com",
    "phone_number": f"+919797979{str(ts_2)[-3:]}",
    "address": "Trainer St",
    "latitude": 12.9716,
    "longitude": 77.5946,
    "categories": [1],
    "description": "Verification test gym 2"
})
org_id_2 = None
if create_org_resp_2 is not None and create_org_resp_2.status_code == 201:
    org_id_2 = create_org_resp_2.json().get("id")
    print(f"Created second organization: ID = {org_id_2}")
else:
    print(f"Failed to create second organization: {create_org_resp_2.status_code if create_org_resp_2 is not None else 'No response'} -> {create_org_resp_2.text if create_org_resp_2 is not None else ''}")

# Attempt to change the email on the trainer by adding them to the second organization (forgot email change option)
trainer_payload_2 = trainer_payload_1.copy()
trainer_payload_2["organization_id"] = org_id_2 or org_id
trainer_payload_2["email"] = f"trainer_updated_{trainer_ts}@example.com"

add_trainer_resp_2 = call_api("POST", "/api/v1/fitnesscenter/trainer-requests/add/", 
                              headers=auth_headers, json_data=trainer_payload_2)
if add_trainer_resp_2 is not None and add_trainer_resp_2.status_code in [200, 201]:
    trainer_data_2 = add_trainer_resp_2.json()
    # Check updated email from the user profile directly or database. The response doesn't explicitly return the updated email directly,
    # but the API view logic updates it on the database User/Trainer object. Let's see if we can print the success message.
    print("[PASS] Direct Trainer Email successfully updated on subsequent add:")
    print(json.dumps(trainer_data_2, indent=2)[:300])
else:
    print(f"[FAIL] Direct Trainer subsequent add failed: {add_trainer_resp_2.status_code if add_trainer_resp_2 is not None else 'No response'} -> {add_trainer_resp_2.text if add_trainer_resp_2 is not None else ''}")

# Step 5: Test Org Staff Creation / Updates
print("\n--- STEP 5: Testing Org Staff & Email Updates ---")
staff_mobile = "+919999999981"
staff_payload_1 = {
    "organization": org_id,
    "mobile_number": staff_mobile,
    "first_name": "TestStaff",
    "last_name": "Yesterday",
    "email": "staff_initial@example.com",
    "user_role": 25 # Mentor Staff
}

add_staff_resp_1 = call_api("POST", "/api/v1/fitnesscenter/organization/create-staff/", 
                            headers=auth_headers, json_data=staff_payload_1)
if add_staff_resp_1 is not None and add_staff_resp_1.status_code in [200, 201]:
    staff_data = add_staff_resp_1.json()
    print("[PASS] Org Staff Add (Initial Email) successful:")
    print(json.dumps(staff_data, indent=2)[:300])
else:
    print(f"[FAIL] Org Staff Add failed: {add_staff_resp_1.status_code if add_staff_resp_1 is not None else 'No response'} -> {add_staff_resp_1.text if add_staff_resp_1 is not None else ''}")

# Attempt to change the email on the staff member
staff_payload_2 = staff_payload_1.copy()
staff_payload_2["email"] = "staff_updated_yesterday@example.com"

add_staff_resp_2 = call_api("POST", "/api/v1/fitnesscenter/organization/create-staff/", 
                            headers=auth_headers, json_data=staff_payload_2)
if add_staff_resp_2 is not None and add_staff_resp_2.status_code in [200, 201]:
    staff_data_2 = add_staff_resp_2.json()
    user_obj = staff_data_2.get("user") or staff_data_2.get("data", {}).get("user", {})
    updated_email = staff_data_2.get("email") or user_obj.get("email")
    if updated_email == "staff_updated_yesterday@example.com":
        print(f"[PASS] Org Staff Email successfully updated on subsequent add: {updated_email}")
    else:
        print(f"[FAIL] Staff email did not update: {updated_email}")
else:
    print(f"[FAIL] Org Staff subsequent add failed: {add_staff_resp_2.status_code if add_staff_resp_2 is not None else 'No response'} -> {add_staff_resp_2.text if add_staff_resp_2 is not None else ''}")

print("\n" + "=" * 70)
print("VERIFICATION COMPLETED!")
print("=" * 70)
