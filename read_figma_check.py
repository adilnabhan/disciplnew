import requests
import json

TOKEN = ""
FILE_KEY = "A7Diis084YpW8oysxaDExH"

headers = {"X-Figma-Token": TOKEN}

# Quick check — just get file metadata first
r = requests.get(
    f"https://api.figma.com/v1/files/{FILE_KEY}?depth=1",
    headers=headers,
    timeout=120,
)

print(f"Status: {r.status_code}")
data = r.json()

if r.status_code != 200:
    print(f"Error: {json.dumps(data, indent=2)}")
else:
    print(f"File name: {data.get('name')}")
    print(f"Last modified: {data.get('lastModified')}")
    doc = data.get("document", {})
    pages = doc.get("children", [])
    print(f"Pages count: {len(pages)}")
    for p in pages:
        print(f"  Page: {p.get('name')} ({p.get('type')})")
        for child in p.get("children", []):
            print(f"    [{child.get('type')}] {child.get('name')}")
