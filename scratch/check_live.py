import urllib.request
import urllib.error
import time

url = "https://discipl-backend.onrender.com/health-check/"
print(f"Checking {url}...")
for i in range(10):
    try:
        response = urllib.request.urlopen(url, timeout=10)
        status = response.getcode()
        print(f"Attempt {i+1}: Success! HTTP Status: {status}")
        break
    except urllib.error.URLError as e:
        print(f"Attempt {i+1}: Failed: {e}")
        time.sleep(10)
