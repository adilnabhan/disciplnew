import requests
import json
import sys

BASE_URL = "https://discipl-backend.onrender.com"
TRAINER_MOBILE = "+919746468282"

# 1. Login to get trainer access token
print("[1] Logging in as trainer...")
r1 = requests.post(f"{BASE_URL}/api/v1/user/send-otp/", json={
    "mobile_number": TRAINER_MOBILE,
    "process": "login",
    "source": "mentor-app-android"
}, headers={"X-Platform": "mentor-app-android"})
otp_data = r1.json()

r2 = requests.post(f"{BASE_URL}/api/v1/user/otp/verify/", json={
    "mobile_number": TRAINER_MOBILE,
    "otp": otp_data.get("otp"),
    "otp_id": otp_data.get("id"),
    "process": "login",
    "source": "mentor-app-android"
}, headers={"X-Platform": "mentor-app-android"})
access_token = r2.json().get("access")
print(f"Logged in successfully. Access token: {access_token[:30]}...")

headers = {
    "Authorization": f"JWT {access_token}",
    "X-Platform": "mentor-app-android",
    "Content-Type": "application/json"
}

# 2. Fetch master exercises from workout-library to get correct IDs
print("\n[2] Fetching workout library...")
r_lib = requests.get(f"{BASE_URL}/api/v1/trainer/exercises/", headers=headers)
print("Workout Library Status:", r_lib.status_code)
if r_lib.status_code != 200:
    print("Error response text:", r_lib.text)
    sys.exit(1)
lib_data = r_lib.json()
if isinstance(lib_data, dict) and "results" in lib_data:
    workouts = lib_data["results"]
else:
    workouts = lib_data

workout_map = {w["name"].lower().strip(): w["id"] for w in workouts}
print(f"Found {len(workout_map)} exercises in library. Examples: {list(workout_map.keys())[:5]}")

# Helper to find workout ID
def get_workout_id(name):
    # Try exact match first
    nid = workout_map.get(name.lower().strip())
    if nid:
        return nid
    # Try partial match
    for wname, wid in workout_map.items():
        if name.lower().strip() in wname:
            return wid
    return None

# 3. Create workout groups
groups_to_create = ["Strength Training", "Cardio & HIIT"]
group_ids = {}

print("\n[3] Checking/Creating workout groups...")
# Fetch existing groups first
r_groups_get = requests.get(f"{BASE_URL}/api/v1/trainer/workout-groups/", headers=headers)
existing_groups = r_groups_get.json()
existing_group_map = {g["name"].lower().strip(): g["id"] for g in existing_groups}

for gname in groups_to_create:
    if gname.lower().strip() in existing_group_map:
        gid = existing_group_map[gname.lower().strip()]
        print(f"Group '{gname}' already exists with ID {gid}")
        group_ids[gname] = gid
    else:
        r_group_post = requests.post(f"{BASE_URL}/api/v1/trainer/workout-groups/", headers=headers, json={
            "name": gname,
            "type": "single_day"
        })
        gid = r_group_post.json()["id"]
        print(f"Created group '{gname}' with ID {gid}")
        group_ids[gname] = gid

# 4. Create workout plans
plans_to_create = [
    {
        "group": "Strength Training",
        "plan_name": "Full Body Blast",
        "description": "A comprehensive full body strength workout.",
        "days": [
            {
                "day_number": 1,
                "title": "Day 1: Full Body Strength",
                "exercises": [
                    {
                        "name": "Barbell Squat",
                        "sets": [
                            {"set_number": 1, "target_reps": 10, "target_weight": 40.0, "rest_seconds": 90},
                            {"set_number": 2, "target_reps": 8, "target_weight": 50.0, "rest_seconds": 90},
                            {"set_number": 3, "target_reps": 6, "target_weight": 60.0, "rest_seconds": 90}
                        ]
                    },
                    {
                        "name": "Barbell Bench Press",
                        "sets": [
                            {"set_number": 1, "target_reps": 12, "target_weight": 30.0, "rest_seconds": 60},
                            {"set_number": 2, "target_reps": 10, "target_weight": 40.0, "rest_seconds": 60},
                            {"set_number": 3, "target_reps": 8, "target_weight": 50.0, "rest_seconds": 60}
                        ]
                    },
                    {
                        "name": "Lat Pulldown",
                        "sets": [
                            {"set_number": 1, "target_reps": 12, "target_weight": 35.0, "rest_seconds": 60},
                            {"set_number": 2, "target_reps": 10, "target_weight": 40.0, "rest_seconds": 60}
                        ]
                    },
                    {
                        "name": "Plank",
                        "sets": [
                            {"set_number": 1, "target_reps": 1, "target_weight": 0.0, "rest_seconds": 60},
                            {"set_number": 2, "target_reps": 1, "target_weight": 0.0, "rest_seconds": 60}
                        ]
                    }
                ]
            }
        ]
    },
    {
        "group": "Strength Training",
        "plan_name": "Upper Body Pump",
        "description": "Focused upper body chest, back, and arms training.",
        "days": [
            {
                "day_number": 1,
                "title": "Day 1: Chest & Arms",
                "exercises": [
                    {
                        "name": "Incline Dumbbell Press",
                        "sets": [
                            {"set_number": 1, "target_reps": 12, "target_weight": 14.0, "rest_seconds": 60},
                            {"set_number": 2, "target_reps": 10, "target_weight": 16.0, "rest_seconds": 60}
                        ]
                    },
                    {
                        "name": "Barbell Bent-Over Row",
                        "sets": [
                            {"set_number": 1, "target_reps": 12, "target_weight": 30.0, "rest_seconds": 60},
                            {"set_number": 2, "target_reps": 10, "target_weight": 35.0, "rest_seconds": 60}
                        ]
                    },
                    {
                        "name": "Lateral Raises",
                        "sets": [
                            {"set_number": 1, "target_reps": 15, "target_weight": 5.0, "rest_seconds": 45},
                            {"set_number": 2, "target_reps": 12, "target_weight": 7.5, "rest_seconds": 45}
                        ]
                    }
                ]
            }
        ]
    },
    {
        "group": "Cardio & HIIT",
        "plan_name": "Fat Burner Routine",
        "description": "High intensity cardio routine.",
        "days": [
            {
                "day_number": 1,
                "title": "Day 1: Cardio Blast",
                "exercises": [
                    {
                        "name": "Treadmill Running",
                        "sets": [
                            {"set_number": 1, "target_reps": 10, "target_weight": 0.0, "rest_seconds": 120}
                        ]
                    },
                    {
                        "name": "Burpees",
                        "sets": [
                            {"set_number": 1, "target_reps": 15, "target_weight": 0.0, "rest_seconds": 60},
                            {"set_number": 2, "target_reps": 15, "target_weight": 0.0, "rest_seconds": 60}
                        ]
                    }
                ]
            }
        ]
    }
]

print("\n[4] Creating workout plans and seeding exercises...")
# Fetch existing plans first to avoid duplicate creation
r_plans_get = requests.get(f"{BASE_URL}/api/v1/trainer/workout-plans/", headers=headers)
print("Plans GET Status:", r_plans_get.status_code)
print("Plans GET Response:", r_plans_get.text)
existing_plans = r_plans_get.json()
if not isinstance(existing_plans, list):
    existing_plans = []
existing_plan_names = {p["plan_name"].lower().strip() for p in existing_plans if isinstance(p, dict) and (p.get("trainer") == 6 or p.get("source") == "trainer")}

for plan_cfg in plans_to_create:
    plan_name = plan_cfg["plan_name"]
    if plan_name.lower().strip() in existing_plan_names:
        print(f"Plan '{plan_name}' already exists, skipping creation.")
        continue
        
    group_id = group_ids[plan_cfg["group"]]
    
    # 1. Create WorkoutPlan
    r_plan_post = requests.post(f"{BASE_URL}/api/v1/trainer/workout-plans/", headers=headers, json={
        "plan_name": plan_name,
        "plan_name_internal": plan_name,
        "description": plan_cfg["description"],
        "group": group_id,
        "total_weeks": 1,
        "total_days": len(plan_cfg["days"])
    })
    
    if r_plan_post.status_code not in [200, 201]:
        print(f"Failed to create plan {plan_name}:", r_plan_post.text)
        continue
        
    plan_id = r_plan_post.json()["id"]
    print(f"\nCreated plan '{plan_name}' with ID {plan_id}")
    
    # 2. For each day in the plan
    for day_cfg in plan_cfg["days"]:
        r_day_post = requests.post(f"{BASE_URL}/api/v1/trainer/workout-plans/{plan_id}/days/", headers=headers, json={
            "day_number": day_cfg["day_number"],
            "title": day_cfg["title"]
        })
        if r_day_post.status_code not in [200, 201]:
            print(f"  Failed to create day {day_cfg['title']}:", r_day_post.text)
            continue
            
        day_id = r_day_post.json()["id"]
        print(f"  Created day '{day_cfg['title']}' with ID {day_id}")
        
        # 3. For each exercise in the day
        for order_idx, ex_cfg in enumerate(day_cfg["exercises"]):
            ex_name = ex_cfg["name"]
            workout_id = get_workout_id(ex_name)
            if not workout_id:
                print(f"    WARNING: Exercise '{ex_name}' not found in master library, skipping.")
                continue
                
            r_ex_post = requests.post(f"{BASE_URL}/api/v1/trainer/plan-days/{day_id}/exercises/", headers=headers, json={
                "workout": workout_id,
                "order_index": order_idx,
                "notes": f"Do your best on {ex_name}!",
                "sets": ex_cfg["sets"]
            })
            if r_ex_post.status_code not in [200, 201]:
                print(f"    Failed to add exercise {ex_name}:", r_ex_post.text)
            else:
                print(f"    Added exercise '{ex_name}' with {len(ex_cfg['sets'])} sets.")

print("\nDone seeding plans!")
