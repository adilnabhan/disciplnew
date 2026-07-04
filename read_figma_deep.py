import requests
import json

TOKEN = ""
FILE_KEY = "A7Diis084YpW8oysxaDExH"

headers = {"X-Figma-Token": TOKEN}

r = requests.get(
    f"https://api.figma.com/v1/files/{FILE_KEY}?depth=5",
    headers=headers,
    timeout=120,
)
data = r.json()

doc = data.get("document", {})
page = doc.get("children", [])[0]

def print_tree(node, indent=0, max_depth=5):
    if indent > max_depth:
        return
    name = node.get("name", "")
    ntype = node.get("type", "")
    
    if ntype in ["SECTION", "FRAME", "COMPONENT", "GROUP"] and name not in ["", "Frame"]:
        prefix = "  " * indent
        print(f"{prefix}[{ntype}] {name}")
    
    for child in node.get("children", [])[:50]:
        child_type = child.get("type", "")
        if child_type in ["SECTION", "FRAME", "COMPONENT", "GROUP"]:
            print_tree(child, indent + 1, max_depth)

# Only Fitness Center section
for child in page.get("children", []):
    if child.get("name") == "Mentor App (User: Fitness Center)":
        print(f"\n{'='*70}")
        print(f"SECTION: {child.get('name')}")
        print(f"{'='*70}")
        print_tree(child, 0, 6)
