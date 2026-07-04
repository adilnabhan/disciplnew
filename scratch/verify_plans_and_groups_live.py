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

# 2. Wait for deployment and verify
for i in range(12):
    print(f"Attempt {i+1} at {time.strftime('%X')}...")
    try:
        r_plans = requests.get(f"{BASE_URL}/api/v1/trainer/workout-plans/", headers=headers, timeout=10)
        r_groups = requests.get(f"{BASE_URL}/api/v1/trainer/workout-groups/", headers=headers, timeout=10)
        
        if r_plans.status_code == 200 and isinstance(r_plans.json(), list):
            plans = r_plans.json()
            groups = r_groups.json()
            
            # Check if diagnostic metadata is gone and we have only templates
            if len(plans) > 0 and "trainer_id" not in plans[0]:
                print("\nDEPLOYMENT FINISHED!")
                print("====================================")
                print(f"Groups ({len(groups)}): {[g['name'] for g in groups]}")
                print(f"Workout Plans ({len(plans)}):")
                for p in plans:
                    print(f"  - ID {p['id']}: {p['plan_name']} (Group: {p['group_name']}, Exercises: {p['exercise_count']})")
                break
            else:
                print("Old version or diagnostic metadata is still active...")
        else:
            print("Status code:", r_plans.status_code)
    except Exception as e:
        print("Error:", e)
    time.sleep(15)
