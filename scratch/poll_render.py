import requests
import json
import time

BASE_URL = "https://discipl-backend.onrender.com"
TRAINER_MOBILE = "+919746468282"

# 1. Send & Verify OTP to get token
r1 = requests.post(f"{BASE_URL}/api/v1/user/send-otp/", json={
    "mobile_number": TRAINER_MOBILE,
    "process": "login",
    "source": "mentor-app-android"
}, headers={"X-Platform": "mentor-app-android"})
otp_data = r1.json()

r2 = requests.post(f"{BASE_URL}/api/v1/user/otp/verify/", json={
    "mobile_number": TRAINER_MOBILE,
    "otp": otp_data.get("otp"),
    "otp_id": otp_data.get("id"),
    "process": "login",
    "source": "mentor-app-android"
}, headers={"X-Platform": "mentor-app-android"})
access_token = r2.json().get("access")

headers = {
    "Authorization": f"JWT {access_token}",
    "X-Platform": "mentor-app-android",
    "Content-Type": "application/json"
}

# 2. Poll the plans API
for i in range(15):
    print(f"Attempt {i+1} at {time.strftime('%X')}...")
    try:
        r = requests.get(f"{BASE_URL}/api/v1/trainer/workout-plans/", headers=headers, timeout=10)
        if r.status_code == 200:
            data = r.json()
            if isinstance(data, dict) and "trainers" in data:
                print("NEW DIAGNOSTIC VERSION DEPLOYED!")
                print("====================================")
                print("TRAINERS:")
                print(json.dumps(data["trainers"], indent=2))
                print("\nLINKS:")
                print(json.dumps(data["links"], indent=2))
                print("\nORGS:")
                print(json.dumps(data["orgs"], indent=2))
                print("\nGROUPS:")
                print(json.dumps(data["groups"], indent=2))
                print("\nPLANS:")
                print(json.dumps(data["plans"], indent=2))
                break
            else:
                print("Normal version is still running (returned list or other data)")
        else:
            print("Status:", r.status_code)
    except Exception as e:
        print("Error:", e)
    time.sleep(15)
