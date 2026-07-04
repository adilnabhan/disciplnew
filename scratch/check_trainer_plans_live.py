import requests
import json

BASE_URL = "https://discipl-backend.onrender.com"
TRAINER_MOBILE = "+919746468282"

# 1. Send & Verify OTP
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

# 2. Get workout plans
print("\n[1] Getting workout plans...")
r_plans = requests.get(f"{BASE_URL}/api/v1/trainer/workout-plans/", headers=headers)
print(f"Status: {r_plans.status_code}")
plans = r_plans.json()
print("Plans count:", len(plans))
print(json.dumps(plans, indent=2))

if plans:
    plan_id = plans[0]['id']
    plan_title = plans[0]['plan_name']
    
    # 3. Get assign status
    print(f"\n[2] Getting assign status for plan ID {plan_id} ({plan_title})...")
    r_assign_get = requests.get(f"{BASE_URL}/api/v1/trainer/workout-plans/{plan_id}/assign/", headers=headers)
    print(f"Status: {r_assign_get.status_code}")
    print(json.dumps(r_assign_get.json(), indent=2))
    
    # 4. Try posting an assignment
    print(f"\n[3] Assigning/Unassigning plan ID {plan_id} to customer ID 15...")
    r_assign_post = requests.post(f"{BASE_URL}/api/v1/trainer/workout-plans/{plan_id}/assign/", headers=headers, json={
        "customer_id": 15
    })
    print(f"Status: {r_assign_post.status_code}")
    print(json.dumps(r_assign_post.json(), indent=2))
