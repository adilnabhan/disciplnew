import requests
import json

TOKEN = ""
FILE_KEY = "A7Diis084YpW8oysxaDExH"

headers = {"X-Figma-Token": TOKEN}

# Get depth=4 to see inside sub-sections
r = requests.get(
    f"https://api.figma.com/v1/files/{FILE_KEY}?depth=4",
    headers=headers,
    timeout=120,
)
data = r.json()

doc = data.get("document", {})
page = doc.get("children", [])[0]  # Page 1

# Collect ALL sections and sub-sections with their frames
def print_tree(node, indent=0):
    name = node.get("name", "")
    ntype = node.get("type", "")
    
    # Only print meaningful nodes
    if ntype in ["SECTION", "FRAME", "COMPONENT"] and name not in ["", "Frame"]:
        prefix = "  " * indent
        print(f"{prefix}[{ntype}] {name}")
    
    for child in node.get("children", [])[:30]:
        child_type = child.get("type", "")
        if child_type in ["SECTION", "FRAME", "COMPONENT"]:
            print_tree(child, indent + 1)

# Focus on main app sections
target_sections = [
    "Customer App Registration UI",
    "Mentor App Registration UI",
    "Mentor App (User: Fitness Center)",
    "Mentor App (User: Trainer)",
    "Mentor App (User: Dietitian)",
    "Customer App",
]

for child in page.get("children", []):
    if child.get("name") in target_sections:
        print(f"\n{'='*65}")
        print_tree(child)
        print(f"{'='*65}")
