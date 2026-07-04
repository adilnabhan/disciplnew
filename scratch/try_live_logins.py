import requests
import json

BASE_URL = "https://discipl-backend.onrender.com"

# Let's try sending OTP and then verifying for +919876547777 and +919876543212
phone_numbers = ["+919876547777", "+919876543212", "+919876543211", "+919495979462", "+919656151233"]

for num in phone_numbers:
    print(f"\n--- Testing number {num} ---")
    # Send OTP
    r1 = requests.post(f"{BASE_URL}/api/v1/user/send-otp/", json={
        "mobile_number": num,
        "process": "login",
        "source": "mentor-app-android" if num != "+919656151233" else "customer-app-android"
    }, headers={"X-Platform": "mentor-app-android"})
    print(f"Send OTP status: {r1.status_code}")
    print(r1.text)

    # Let's try to verify with OTP "0000"
    r2 = requests.post(f"{BASE_URL}/api/v1/user/otp/verify/", json={
        "mobile_number": num,
        "otp": "0000"
    }, headers={"X-Platform": "mentor-app-android"})
    print(f"Verify status with 0000: {r2.status_code}")
    if r2.status_code in [200, 201]:
        print("Success! Got token:")
        print(json.dumps(r2.json(), indent=2))
        continue
    
    # Try verification with "1234"
    r2 = requests.post(f"{BASE_URL}/api/v1/user/otp/verify/", json={
        "mobile_number": num,
        "otp": "1234"
    }, headers={"X-Platform": "mentor-app-android"})
    print(f"Verify status with 1234: {r2.status_code}")
    if r2.status_code in [200, 201]:
        print("Success! Got token:")
        print(json.dumps(r2.json(), indent=2))
        continue
