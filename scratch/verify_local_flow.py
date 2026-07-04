import requests
import json

BASE_URL = "http://127.0.0.1:8000"

def get_auth_headers(mobile_number, platform="mentor-app-android"):
    # 1. Send OTP
    print(f"\n[Auth] Sending OTP for {mobile_number}...")
    r1 = requests.post(f"{BASE_URL}/api/v1/user/send-otp/", json={
        "mobile_number": mobile_number,
        "process": "login",
        "source": platform
    }, headers={"X-Platform": platform})
    
    if r1.status_code not in [200, 201]:
        print(f"[Auth Error] send-otp returned status {r1.status_code}: {r1.text}")
        return None
        
    otp_data = r1.json()
    otp = otp_data.get("otp")
    otp_id = otp_data.get("id")
    print(f"[Auth] OTP received: {otp}")
    
    # 2. Verify OTP
    print(f"[Auth] Verifying OTP {otp} for {mobile_number}...")
    r2 = requests.post(f"{BASE_URL}/api/v1/user/otp/verify/", json={
        "mobile_number": mobile_number,
        "otp": otp,
        "otp_id": otp_id,
        "process": "login",
        "source": platform
    }, headers={"X-Platform": platform})
    
    if r2.status_code not in [200, 201]:
        print(f"[Auth Error] verify-otp returned status {r2.status_code}: {r2.text}")
        return None
        
    token_data = r2.json()
    access_token = token_data.get("data", {}).get("access_token")
    if not access_token:
        access_token = token_data.get("access")
    
    print(f"[Auth] Login successful. Access token length: {len(access_token) if access_token else 0}")
    
    return {
        "Authorization": f"JWT {access_token}",
        "X-Platform": platform,
        "Content-Type": "application/json"
    }

def main():
    print("=== STARTING LOCAL FLOW E2E VERIFICATION ===")
    
    # 1. Login as Gym Owner (TestMentor API: +919876543211)
    owner_headers = get_auth_headers("+919876543211")
    if not owner_headers:
        print("Failed to authenticate as Gym Owner.")
        return
        
    # Get Owner info/Organization details using GET /api/v1/user/login/
    print("\n[Gym Owner] Fetching profile / gym details...")
    profile_res = requests.get(f"{BASE_URL}/api/v1/user/login/", headers=owner_headers)
    print(f"Profile Status: {profile_res.status_code}")
    profile_data = profile_res.json()
    print("Profile Details (first 300 chars):", str(profile_data)[:300])
    
    # Let's search for organization ID in profile_data
    org_id = profile_data.get("mentor", {}).get("organization", {}).get("id")
    if not org_id:
        print("Could not find organization_id in profile. Querying organization endpoint...")
        org_res = requests.get(f"{BASE_URL}/api/v1/fitnesscenter/organization/", headers=owner_headers)
        if org_res.status_code == 200:
            orgs = org_res.json()
            if isinstance(orgs, list) and len(orgs) > 0:
                org_id = orgs[0].get("id")
            elif isinstance(orgs, dict) and "results" in orgs:
                org_id = orgs["results"][0].get("id")
    
    if not org_id:
        print("Could not find organization_id dynamically. Using fallback 1.")
        org_id = 1
        
    print(f"Using Organization ID: {org_id}")
    
    # 2. Add a new trainer under this organization
    trainer_mobile = "+919876545555"
    print(f"\n[Gym Owner] Creating a trainer with mobile {trainer_mobile}...")
    trainer_data = {
        "first_name": "John",
        "last_name": "Doe",
        "email": "johndoe_test@example.com",
        "mobile_number": trainer_mobile,
        "organization_id": org_id,
        "experience": 5,
        "specialization": "Bodybuilding",
        "gender": "male"
    }
    
    create_res = requests.post(f"{BASE_URL}/api/v1/mentor/trainers/", json=trainer_data, headers=owner_headers)
    print(f"Trainer Creation Status: {create_res.status_code}")
    print("Trainer Creation Response:", create_res.text)
    
    # 3. Log in as the new trainer
    trainer_headers = get_auth_headers(trainer_mobile)
    if not trainer_headers:
        print("Failed to authenticate as the new Trainer.")
        return
        
    # Get trainer profile using GET /api/v1/user/login/
    print("\n[Trainer] Fetching trainer profile...")
    trainer_profile_res = requests.get(f"{BASE_URL}/api/v1/user/login/", headers=trainer_headers)
    print(f"Trainer Profile Status: {trainer_profile_res.status_code}")
    trainer_profile_data = trainer_profile_res.json()
    print("Trainer Profile Data:", json.dumps(trainer_profile_data, indent=2))

    trainer_id = trainer_profile_data.get("trainer", {}).get("id")
    print(f"Trainer Profile ID: {trainer_id}")

    # Get trainer dashboard stats
    print("\n[Trainer] Fetching trainer dashboard/statistics...")
    stats_res = requests.get(f"{BASE_URL}/api/v1/trainer/dashboard/", headers=trainer_headers)
    print(f"Dashboard Stats Status: {stats_res.status_code}")
    print("Dashboard Stats Response:", stats_res.text[:500])
    
    # 4. Gym Owner assigns a customer to the trainer
    # Let's find a customer ID first. We saw +919797979797 is Test Customer (role 45)
    customer_headers = get_auth_headers("+919797979797", platform="customer-app-android")
    if not customer_headers:
        print("Failed to authenticate as Customer.")
        return
        
    print("\n[Customer] Fetching customer profile details...")
    cust_login_res = requests.get(f"{BASE_URL}/api/v1/user/login/", headers=customer_headers)
    print(f"Customer User/Login Status: {cust_login_res.status_code}")
    cust_login_data = cust_login_res.json()
    print("Customer User/Login Response:", str(cust_login_data)[:500])
    
    customer_id = cust_login_data.get("customer", {}).get("id")
    print(f"Customer Model ID: {customer_id}")
    
    if not customer_id:
        print("Failed to get Customer Model ID. Exiting assignment tests.")
        return

    # Check customer details via GET /api/v1/customer/manage/<customer_id>/
    print(f"\n[Customer] Fetching customer details for ID {customer_id}...")
    cust_detail_res = requests.get(f"{BASE_URL}/api/v1/customer/manage/{customer_id}/", headers=customer_headers)
    print(f"Customer Details Status: {cust_detail_res.status_code}")
    cust_detail_data = cust_detail_res.json()
    print("Customer Details (first 300 chars):", str(cust_detail_data)[:300])

    if trainer_id:
        print(f"\n[Gym Owner] Assigning Trainer {trainer_id} to Customer {customer_id}...")
        # Gym Owners can update customer details (including assigning a trainer)
        # Endpoint: PATCH /api/v1/customer/manage/<customer_id>/update/ or similar?
        # Let's check CustomerUpdateView in urls: path('<int:pk>/update/', CustomerUpdateView.as_view())
        # Wait, the URL path is /api/v1/customer/manage/<pk>/update/
        assign_res = requests.patch(f"{BASE_URL}/api/v1/customer/manage/{customer_id}/update/", json={
            "trainer_id": trainer_id
        }, headers=owner_headers)
        print(f"Assign Status: {assign_res.status_code}")
        print("Assign Response:", assign_res.text[:500])
        
        # 5. Verify Customer Profile returns the assigned gym and trainer
        print("\n[Customer] Re-fetching customer details to check assigned gym and trainer...")
        cust_detail_res2 = requests.get(f"{BASE_URL}/api/v1/customer/manage/{customer_id}/", headers=customer_headers)
        print(f"Customer Details Status: {cust_detail_res2.status_code}")
        cust_detail_data2 = cust_detail_res2.json()
        
        assigned_gym = cust_detail_data2.get("assigned_fitness_center")
        assigned_trainer = cust_detail_data2.get("assigned_trainer")
        print("Assigned Gym (name):", assigned_gym.get("name") if assigned_gym else None)
        print("Assigned Trainer (name):", assigned_trainer.get("name") if assigned_trainer else None)
        
        # 6. Verify Trainer lists the assigned customer
        print("\n[Trainer] Fetching assigned customers...")
        # Endpoint: /api/v1/trainer/customers/
        trainer_cust_res = requests.get(f"{BASE_URL}/api/v1/trainer/customers/", headers=trainer_headers)
        print(f"Trainer Customers Status: {trainer_cust_res.status_code}")
        trainer_cust_data = trainer_cust_res.json()
        print("Trainer Customers:", json.dumps(trainer_cust_data, indent=2))
        
        # 7. Update progress notes for customer as Trainer
        print(f"\n[Trainer] Updating progress notes for Customer {customer_id}...")
        notes_res = requests.put(f"{BASE_URL}/api/v1/trainer/customers/{customer_id}/", json={
            "trainer_notes": "Client needs to focus on squats and bench press. Target: increase weight by 5kg next week."
        }, headers=trainer_headers)
        print(f"Update Notes Status: {notes_res.status_code}")
        print("Update Notes Response:", notes_res.text)
        
        # Verify it was updated in customer details
        print("\n[Customer] Re-fetching customer details to verify trainer notes...")
        cust_detail_res3 = requests.get(f"{BASE_URL}/api/v1/customer/manage/{customer_id}/", headers=customer_headers)
        print("Trainer Notes in Customer Details:", cust_detail_res3.json().get("trainer_notes", "Not Found"))

if __name__ == "__main__":
    main()
