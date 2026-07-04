import requests
import json

BASE_URL = "https://discipl-backend.onrender.com"
TRAINER_MOBILE = "+919746468282"

print("=" * 80)
print(f"TESTING TRAINER LIVE API: {TRAINER_MOBILE}")
print("=" * 80)

# 1. Send OTP
print("\n[1] Sending OTP...")
r1 = requests.post(f"{BASE_URL}/api/v1/user/send-otp/", json={
    "mobile_number": TRAINER_MOBILE,
    "process": "login",
    "source": "mentor-app-android"
}, headers={"X-Platform": "mentor-app-android"})

print(f"Status: {r1.status_code}")
if r1.status_code not in [200, 201]:
    print(r1.text)
    exit(1)

otp_data = r1.json()
otp = otp_data.get("otp")
otp_id = otp_data.get("id")
print(f"OTP received: {otp}, OTP ID: {otp_id}")

# 2. Verify OTP
print("\n[2] Verifying OTP...")
r2 = requests.post(f"{BASE_URL}/api/v1/user/otp/verify/", json={
    "mobile_number": TRAINER_MOBILE,
    "otp": otp,
    "otp_id": otp_id,
    "process": "login",
    "source": "mentor-app-android"
}, headers={"X-Platform": "mentor-app-android"})

print(f"Status: {r2.status_code}")
if r2.status_code not in [200, 201]:
    print(r2.text)
    exit(1)

user_data = r2.json()
print("User Data:")
print(json.dumps(user_data, indent=2))

access_token = user_data.get("data", {}).get("access_token") or user_data.get("access")
if not access_token:
    print("No access token found.")
    exit(1)

headers = {
    "Authorization": f"Bearer {access_token}",
    "X-Platform": "mentor-app-android",
    "Content-Type": "application/json"
}

# 3. Fetch Trainer Dashboard
print("\n[3] Fetching Trainer Dashboard...")
r3 = requests.get(f"{BASE_URL}/api/v1/trainer/dashboard/", headers=headers)
print(f"Status: {r3.status_code}")
print(json.dumps(r3.json(), indent=2))

# 4. Fetch Trainer Customers
print("\n[4] Fetching Trainer Customers (status=all)...")
r4 = requests.get(f"{BASE_URL}/api/v1/trainer/customers/?status=all", headers=headers)
print(f"Status: {r4.status_code}")
print(json.dumps(r4.json(), indent=2))

# 5. Fetch Trainer Customers (status=active)
print("\n[5] Fetching Trainer Customers (status=active)...")
r5 = requests.get(f"{BASE_URL}/api/v1/trainer/customers/?status=active", headers=headers)
print(f"Status: {r5.status_code}")
print(json.dumps(r5.json(), indent=2))
