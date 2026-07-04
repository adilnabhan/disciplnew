import requests
import json
import sys

BASE_URL = "https://discipl-backend.onrender.com"

print("=" * 80)
print(f"VERIFYING WORKOUT APIs on live deployment: {BASE_URL}")
print("=" * 80)

# 1. Health Check
print("\n[1] Hitting Health Check...")
try:
    r = requests.get(f"{BASE_URL}/health-check/", headers={"X-Platform": "customer-app-android"}, timeout=15)
    print(f"Status: {r.status_code}")
    print(r.text[:100])
except Exception as e:
    print(f"Error: {e}")

# 2. Guest Login to get token
print("\n[2] Logging in as Guest...")
try:
    r = requests.post(f"{BASE_URL}/api/v1/user/login/guest/", json={}, headers={"X-Platform": "customer-app-android"}, timeout=15)
    print(f"Status: {r.status_code}")
    guest_data = r.json()
    token_data = guest_data.get("data", {}) if "data" in guest_data else guest_data
    access_token = token_data.get("access_token") or token_data.get("access")
    print(f"Access Token: {access_token[:30] if access_token else None}...")
except Exception as e:
    print(f"Error logging in: {e}")
    sys.exit(1)

if not access_token:
    print("Could not obtain access token, aborting authed tests.")
    sys.exit(1)

headers = {
    "Authorization": f"Bearer {access_token}",
    "X-Platform": "customer-app-android",
    "Content-Type": "application/json"
}

# 3. Fetch Customer Homepage
print("\n[3] Fetching Customer Homepage (authed)...")
try:
    r = requests.get(f"{BASE_URL}/api/v1/customer/customer-homepage/", headers=headers, timeout=15)
    print(f"Status: {r.status_code}")
    print(r.text[:150])
except Exception as e:
    print(f"Error: {e}")

# 4. Fetch Constant Choices
print("\n[4] Fetching Constant Choices (authed)...")
try:
    r = requests.get(f"{BASE_URL}/api/v1/customer/constant-choices/", headers=headers, timeout=15)
    print(f"Status: {r.status_code}")
    print(r.text[:150])
except Exception as e:
    print(f"Error: {e}")

# 5. Fetch Presets
print("\n[5] Fetching Workout Presets (authed)...")
try:
    r = requests.get(f"{BASE_URL}/api/v1/customer/presets/", headers=headers, timeout=15)
    print(f"Status: {r.status_code}")
    print(r.text[:150])
except Exception as e:
    print(f"Error: {e}")

# 6. Fetch Workout Log for today
print("\n[6] Fetching Workout Log for date 2026-06-20 (authed)...")
try:
    r = requests.get(f"{BASE_URL}/api/v1/customer/workout-log/?date=2026-06-20", headers=headers, timeout=15)
    print(f"Status: {r.status_code}")
    print(json.dumps(r.json(), indent=2)[:300])
except Exception as e:
    print(f"Error: {e}")

# 7. Test rest day toggle endpoint behavior
print("\n[7] Testing rest day toggle behavior (authed)...")
try:
    r = requests.post(f"{BASE_URL}/api/v1/customer/sessions/rest-day/", headers=headers, json={
        "plan_day_id": 9999,
        "date": "2026-06-20",
        "is_rest_day": True
    }, timeout=15)
    print(f"Status (non-existent plan_day expected 400/404): {r.status_code}")
    print(r.text[:200])
except Exception as e:
    print(f"Error: {e}")

# 8. Check that no local Django is running on the computer
print("\n[8] Checking if local Django server is running on http://127.0.0.1:8000...")
try:
    r = requests.get("http://127.0.0.1:8000/health-check/", timeout=5)
    print(f"WARNING: A local Django server IS running on http://127.0.0.1:8000 (status: {r.status_code})")
except requests.exceptions.ConnectionError:
    print("SUCCESS: Confirmed no local Django server is running on http://127.0.0.1:8000 (Connection Refused).")
except Exception as e:
    print(f"Confirmed no local Django server running. Diagnostic info: {e}")

print("\n" + "=" * 80)
print("LIVE WORKOUT API VERIFICATION COMPLETE")
print("=" * 80)
sys.exit(0)

