import requests
import json

BASE_URL = "https://discipl-backend.onrender.com"

# 1. Send OTP for admin
r1 = requests.post(f"{BASE_URL}/api/v1/user/send-otp/", json={
    "mobile_number": "+919495979462",
    "process": "login",
    "source": "mentor-app-android"
}, headers={"X-Platform": "mentor-app-android"})
otp_data = r1.json()
otp = otp_data.get("otp")
print(f"OTP sent, received OTP: {otp}")

# 2. Verify OTP
r2 = requests.post(f"{BASE_URL}/api/v1/user/otp/verify/", json={
    "mobile_number": "+919495979462",
    "otp": otp,
    "otp_id": otp_data.get("id"),
    "process": otp_data.get("process"),
    "source": otp_data.get("source")
}, headers={"X-Platform": "mentor-app-android"})
print(f"Verify status: {r2.status_code}")
print(r2.text)
token_data = r2.json()
access_token = token_data.get("data", {}).get("access_token") or token_data.get("access")
print(f"Access token: {access_token[:30] if access_token else None}")

if access_token:
    headers = {
        "Authorization": f"JWT {access_token}",
        "X-Platform": "mentor-app-android",
        "Content-Type": "application/json"
    }
    
    # 3. Get organization details for 1021
    r3 = requests.get(f"{BASE_URL}/api/v1/fitnesscenter/organization/1021/", headers=headers)
    print("Org 1021 Details:")
    org_data = r3.json()
    print(json.dumps(org_data, indent=2))
