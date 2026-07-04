
import requests

BASE_URL = "http://localhost:8000/api/v1/trainer/trainers"
TOKEN = "YOUR_ACCESS_TOKEN" # This needs to be a real token from login

def test_combined_experience():
    url = f"{BASE_URL}/experience/"
    headers = {"Authorization": f"Bearer {TOKEN}"}
    
    # Combined data: experience years, bio, specializations, and certificates
    data = {
        "experience_years": 8,
        "bio": "Expert Trainer with multi-upload support",
        "specializations": "[1, 2]",
        "certificate_names": ["NSCA Certified", "ACE Certified"]
    }
    
    # Generate dummy files
    files = [
        ('certificate_files', ('nsca.pdf', b'fake pdf content 1', 'application/pdf')),
        ('certificate_files', ('ace.pdf', b'fake pdf content 2', 'application/pdf'))
    ]
    
    response = requests.post(url, data=data, files=files, headers=headers)
    print("Experience Response:", response.json())

def test_multi_recognition():
    url = f"{BASE_URL}/recognitions/"
    headers = {"Authorization": f"Bearer {TOKEN}"}
    
    data = {
        "description": ["Winning first place", "New transformation"]
    }
    
    files = [
        ('image_from', ('before1.jpg', b'fake img 1', 'image/jpeg')),
        ('image_from', ('before2.jpg', b'fake img 2', 'image/jpeg')),
        ('image_to', ('after1.jpg', b'fake img 3', 'image/jpeg')),
        ('image_to', ('after2.jpg', b'fake img 4', 'image/jpeg'))
    ]
    
    response = requests.post(url, data=data, files=files, headers=headers)
    print("Recognition Response:", response.json())

if __name__ == "__main__":
    # Note: These need a real token to work. I'll test logic via unit tests if possible.
    print("Test script ready. Requires valid TOKEN.")
