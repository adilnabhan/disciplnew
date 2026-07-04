import requests
import json

BASE_URL = "https://discipl-backend.onrender.com"
token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzgyMzgwMTY3LCJpYXQiOjE3ODIyMDczNjcsImp0aSI6IjFiZWRmNmUwNzAxMjQwODBiZmY5ZGQ2MjEzM2Q4YzQyIiwidXNlcl9pZCI6IjQ2MyIsInJvbGUiOjIwLCJ1c2VybmFtZSI6ImNiZjYyYzA3LWVhZmUtNDY1Yi04MWU0LTc2NjhjM2RmOTU1ZCIsIm1vYmlsZV9udW1iZXIiOiIrOTE5NDk1OTc5NDYyIn0.qWOZFxl2LrynVsCOfAJ7eU6MozF3kU1_jGX_DZ0Z6S4"

headers = {
    "Authorization": f"JWT {token}",
    "X-Platform": "mentor-app-android",
    "Content-Type": "application/json"
}

# 1. Get workout plans
print("Fetching workout plans...")
r = requests.get(f"{BASE_URL}/api/v1/trainer/workout-plans/", headers=headers)
print(f"Plans status: {r.status_code}")
plans = r.json()
print(json.dumps(plans, indent=2))

if plans and isinstance(plans, list):
    plan_id = plans[0]['id']
    print(f"\nFetching customers list for plan {plan_id}...")
    r2 = requests.get(f"{BASE_URL}/api/v1/trainer/workout-plans/{plan_id}/assign/", headers=headers)
    print(f"Customers list status: {r2.status_code}")
    print(json.dumps(r2.json(), indent=2))
