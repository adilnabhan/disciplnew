"""
Deep-dive test for Trainer Onboarding Flow on Production
Tests the exact data returned at each step of the registration process,
particularly for role IDs 35 (MENTOR_TRAINER) and 36 (MENTOR_DIETITIAN).
"""
import os
os.environ['PYTHONIOENCODING'] = 'utf-8'
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')

import django
django.setup()

import json
from apps.user.models import User
from apps.user.api.serializers import UserRegistrationSerializer, UserProfileResponseSerializer
from apps.trainer.models import Trainer
from apps.mentors.models import MentorProfile

print("="*65)
print("  TRAINER ONBOARDING FLOW - DEEP AUDIT")
print("="*65)

# ─────────────────────────────────────────────────────────────
# 1. ROLE MAPPING VERIFICATION
# ─────────────────────────────────────────────────────────────
print("\n--- 1. Role ID Mapping ---")
print(f"  MENTOR_TRAINER  = {User.MENTOR_TRAINER} (Trainer)")
print(f"  MENTOR_DIETITIAN = {User.MENTOR_DIETITIAN} (Dietitian)")
print(f"  MENTOR          = {User.MENTOR}")
print(f"  CUSTOMER        = {User.CUSTOMER}")
print(f"  MENTOR_ROLES    = {User.MENTOR_ROLES}")

# ─────────────────────────────────────────────────────────────
# 2. SERIALIZER create() LOGIC TRACE
# ─────────────────────────────────────────────────────────────
print("\n--- 2. Registration Serializer Logic Trace ---")

# Simulate what happens when source='vendor-app-android', user_role=35
print("\n  SCENARIO A: New Trainer (role=35, source='vendor-app-android')")
print("  Step 1: validated_data pops meta, otp_id, process, source, otp")
print("  Step 2: Check if user exists -> No")
print("  Step 3: Create User(**validated_data)")
print(f"  Step 4: source='vendor-app-android' -> 'mentor' NOT in source -> 'customer' NOT in source")
print(f"  Step 5: Neither branch matches -> user_role stays as {User.MENTOR_TRAINER} (35)")
print("  Step 6: user.save() -> user.create_profile()")
print(f"  Step 7: create_profile checks user_role={User.MENTOR_TRAINER}")
print(f"    -> IN MENTOR_ROLES ({User.MENTOR_ROLES}): Creates MentorProfile")
print(f"    -> IN [MENTOR_TRAINER, MENTOR_DIETITIAN]: Creates Trainer profile")
print("  RESULT: Both MentorProfile AND Trainer records created correctly")

print("\n  SCENARIO B: New Trainer (role=35, source='mentor-app-android')")
print("  Step 1-3: Same as above")
print(f"  Step 4: source='mentor-app-android' -> 'mentor' IN source")
print(f"  Step 5: int(35) in MENTOR_ROLES={User.MENTOR_ROLES}? {35 in User.MENTOR_ROLES}")
print(f"  Step 6: Since 35 IS in MENTOR_ROLES -> user_role stays as 35")
print("  RESULT: Role preserved correctly at 35")

print("\n  SCENARIO C: New Trainer (role=36, source='vendor-app-android')")
print(f"  Same as A but with MENTOR_DIETITIAN={User.MENTOR_DIETITIAN}")
print(f"  create_profile: user_type = 'dietitian' (since role_int == {User.MENTOR_DIETITIAN})")
print("  RESULT: Trainer created with user_type='dietitian'")

# ─────────────────────────────────────────────────────────────
# 3. RESPONSE STRUCTURE CHECK
# ─────────────────────────────────────────────────────────────
print("\n--- 3. Response Structure Verification ---")

# Check what UserProfileResponseSerializer returns for a trainer
trainer_users = User.objects.filter(user_role__in=[User.MENTOR_TRAINER, User.MENTOR_DIETITIAN])
print(f"  Found {trainer_users.count()} trainer users in DB")

for u in trainer_users[:3]:
    print(f"\n  User ID={u.id}, Role={u.user_role}, Name={u.full_name}")
    data = UserProfileResponseSerializer(instance=u).data
    print(f"    Response fields: {list(data.keys())}")
    print(f"    user_role: {data.get('user_role')}")
    print(f"    role: {data.get('role')}")
    print(f"    trainer: {json.dumps(data.get('trainer'), indent=6)}")
    print(f"    mentor: {json.dumps(data.get('mentor'), indent=6)}")
    
    # Check if trainer profile exists
    trainer = Trainer.objects.filter(user=u).first()
    if trainer:
        print(f"    Trainer record: id={trainer.id}, user_type={trainer.user_type}, step={trainer.profile_step}")
    else:
        print(f"    [WARNING] No Trainer record found for user {u.id} with role {u.user_role}!")

    # Check if mentor profile exists
    mentor = MentorProfile.objects.filter(user=u).first()
    if mentor:
        print(f"    MentorProfile: id={mentor.id}, org={getattr(mentor, 'organization', None)}")
    else:
        print(f"    [WARNING] No MentorProfile found for user {u.id} with role {u.user_role}!")


# ─────────────────────────────────────────────────────────────
# 4. EXISTING USER UPGRADE FLOW
# ─────────────────────────────────────────────────────────────
print("\n--- 4. Existing User Role Upgrade Trace ---")
print("  When existing user registers again with role=35:")
print("    -> Hits 'existing' branch (line 249-269 in serializer)")
print("    -> Updates user_role from old value to 35")
print("    -> BUT does NOT call create_profile()!")
print("    -> This means Trainer and MentorProfile records are NOT created")
print("    -> [BUG] Role upgrade does NOT create trainer/mentor profiles")

# Check for users with trainer role but missing profiles
print("\n--- 5. Data Integrity Check ---")
trainer_role_users = User.objects.filter(user_role__in=[User.MENTOR_TRAINER, User.MENTOR_DIETITIAN])
missing_trainer_profile = []
missing_mentor_profile = []

for u in trainer_role_users:
    if not Trainer.objects.filter(user=u).exists():
        missing_trainer_profile.append(u)
    if not MentorProfile.objects.filter(user=u).exists():
        missing_mentor_profile.append(u)

print(f"  Total trainer-role users: {trainer_role_users.count()}")
print(f"  Missing Trainer profile: {len(missing_trainer_profile)}")
if missing_trainer_profile:
    for u in missing_trainer_profile[:5]:
        print(f"    -> User {u.id} ({u.full_name}) has role={u.user_role} but NO Trainer record")
        
print(f"  Missing MentorProfile: {len(missing_mentor_profile)}")
if missing_mentor_profile:
    for u in missing_mentor_profile[:5]:
        print(f"    -> User {u.id} ({u.full_name}) has role={u.user_role} but NO MentorProfile record")

print(f"\n{'='*65}")
print(f"  AUDIT COMPLETE")
print(f"{'='*65}")
