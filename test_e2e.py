"""
Quick test: Use pre-generated token to test Trainer APIs
"""
import requests
import json

BASE = "http://localhost:8000/api/v1"
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"  # placeholder, will be replaced

# Read the token from shell output
import subprocess
result = subprocess.run(
    ['python', 'manage.py', 'shell', '-c',
     'from apps.user.models import User; u = User.objects.get(id=1); '
     'from apps.utils.token_encoder import jwt_encode; '
     'tokens = jwt_encode(u, platform=None); print(tokens["access_token"])'],
    capture_output=True, text=True
)
TOKEN = result.stdout.strip().split('\n')[-1]  # last line = token
print(f"Token: {TOKEN[:40]}...")

AUTH = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {TOKEN}",
    "X-Platform": "mentor-app-android"
}

def step(name):
    print(f"\n{'='*60}")
    print(f"  {name}")
    print(f"{'='*60}")

def show(r):
    print(f"  Status: {r.status_code}")
    try:
        data = r.json()
        text = json.dumps(data, indent=2)
        if len(text) > 800:
            print(f"  Response: {text[:800]}...")
        else:
            print(f"  Response: {text}")
        return data
    except:
        print(f"  Response (text): {r.text[:500]}")
        return {}

# ──── Test 1: GET Trainer ID=4 (THE FIX) ────
step("1 - GET /trainer/trainers/4/ (ProgrammingError fix)")
show(requests.get(f"{BASE}/trainer/trainers/4/", headers=AUTH))

# ──── Test 2: GET Trainer by User ID ────
step("2 - GET /trainer/trainers/5/ (user_id=5 → trainer_id=4)")
show(requests.get(f"{BASE}/trainer/trainers/5/", headers=AUTH))

# ──── Test 3: List Trainers ────
step("3 - GET /trainer/trainers/ (List All)")
show(requests.get(f"{BASE}/trainer/trainers/", headers=AUTH))

# ──── Test 4: Workout Groups ────
step("4 - GET /trainer/workout-groups/?type=single_day")
show(requests.get(f"{BASE}/trainer/workout-groups/?type=single_day", headers=AUTH))

# ──── Test 5: Workout Plans ────
step("5 - GET /trainer/workout-plans/")
show(requests.get(f"{BASE}/trainer/workout-plans/", headers=AUTH))

# ──── Test 6: Specializations ────
step("6 - GET /trainer/specializations/")
show(requests.get(f"{BASE}/trainer/specializations/", headers=AUTH))

# ──── Test 7: Languages ────
step("7 - GET /trainer/languages/")
show(requests.get(f"{BASE}/trainer/languages/", headers=AUTH))

print(f"\n{'='*60}")
print(f"  ALL TESTS COMPLETE")
print(f"{'='*60}\n")
