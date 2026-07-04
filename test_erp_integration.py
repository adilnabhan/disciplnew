import requests

# Step 1: Login
login_res = requests.post(
    'http://localhost:8000/api/v1/user/login/',
    json={'username': 'test_mentor@discipl.com', 'password': 'Password@123'},
    headers={'X-Platform': 'mentor-app-web', 'Content-Type': 'application/json'}
)
print(f"Login: {login_res.status_code}")
data = login_res.json()
token = data.get('access')
mentor = data.get('mentor')
print(f"Token: {token[:50]}...")
print(f"Mentor data: {mentor}")
print(f"User role: {data.get('user_role')}")

# Step 2: Fetch organization list
headers = {
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json',
    'X-Platform': 'mentor-app-web'
}

org_res = requests.get(
    'http://localhost:8000/api/v1/fitnesscenter/organization/list/',
    headers=headers
)
print(f"\nOrg list: {org_res.status_code}")
org_data = org_res.json()
print(f"Org response: {str(org_data)[:500]}")

if org_data.get('success') and org_data.get('result'):
    org_id = org_data['result'][0]['id']
    print(f"\nOrg ID: {org_id}")

    # Step 3: Fetch org details
    detail_res = requests.get(
        f'http://localhost:8000/api/v1/fitnesscenter/organization/{org_id}/',
        headers=headers
    )
    print(f"Org detail: {detail_res.status_code}")
    detail = detail_res.json()
    print(f"Name: {detail.get('name')}")
    print(f"Categories: {detail.get('categories')}")
    print(f"Amenities: {detail.get('amenities')}")
    print(f"Working days: {len(detail.get('working_days', []))}")
    print(f"Time slots: {len(detail.get('time_slots', []))}")
    print(f"Packages: {len(detail.get('packages', []))}")
else:
    print("No organizations found for this mentor!")
    # Try with mentor_* usernames
    print("\nTrying a gym-based mentor login...")
    login2 = requests.post(
        'http://localhost:8000/api/v1/user/login/',
        json={'username': 'mentor_aarc1-fitness-petta', 'password': 'Password@123'},
        headers={'X-Platform': 'mentor-app-web', 'Content-Type': 'application/json'}
    )
    print(f"Gym mentor login: {login2.status_code}")
    if login2.status_code == 200:
        d2 = login2.json()
        t2 = d2['access']
        h2 = {**headers, 'Authorization': f'Bearer {t2}'}
        org_res2 = requests.get(
            'http://localhost:8000/api/v1/fitnesscenter/organization/list/',
            headers=h2
        )
        print(f"Org list for gym mentor: {org_res2.status_code}")
        print(f"Response: {str(org_res2.json())[:500]}")
