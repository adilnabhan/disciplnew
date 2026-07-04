import requests
import json

# Token from the app log (valid for ~2 days)
TOKEN = "JWT eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzgyNDUyODU5LCJpYXQiOjE3ODIyODAwNTksImp0aSI6IjBmZmZjMTY1MTNkMDRiNjU5OWQ3Y2VmN2M3Y2NiNDlkIiwidXNlcl9pZCI6IjQ4MSIsInJvbGUiOjIwLCJ1c2VybmFtZSI6IjI4MjJlYjAxLTgxODYtNGEzYy1iMDY3LTRkOTA2NGI5ZWVhYSIsIm1vYmlsZV9udW1iZXIiOiIrOTE5NDk1OTc5NDYyIn0.XK8lRvMIYoV5CMAoTXsK4nkbAr7WSVC-5CA0FQYUXt4"

# Local Server Check
LOCAL_URL = "http://127.0.0.1:8000/api/v1/fitnesscenter/organization/create/"
# Render Server Check
RENDER_URL = "https://discipl-backend.onrender.com/api/v1/fitnesscenter/organization/create/"

payload = {
    "name": "Test Gym",
    "description": "Test Gym Description",
    "email": "testgym@gmail.com",
    "phone_number": "+919495979462",
    "location": {
        "building_name": "Test",
        "street": "Poovangal", # 9 chars (less than 10, more than 3)
        "city": "Kozhikode",
        "state": "Kerala",
        "pin_code": "673014"
    },
    "working_days": [],
    "categories": [1],
    "amenities": [1]
}

headers = {
    "X-Platform": "mentor-app-android",
    "Authorization": TOKEN,
    "Content-Type": "application/json"
}

print("=== TESTING LOCAL BACKEND ===")
try:
    r_local = requests.post(LOCAL_URL, json=payload, headers=headers)
    print(f"Status: {r_local.status_code}")
    print(r_local.json())
except Exception as e:
    print(f"Error checking local: {e}")

print("\n=== TESTING RENDER BACKEND ===")
try:
    r_render = requests.post(RENDER_URL, json=payload, headers=headers)
    print(f"Status: {r_render.status_code}")
    print(r_render.json())
except Exception as e:
    print(f"Error checking render: {e}")
