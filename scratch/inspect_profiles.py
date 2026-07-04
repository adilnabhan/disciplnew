import os
import sys
import django

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from apps.mentors.models import MentorProfile
from apps.fitnesscenter.models import Organization
from apps.trainer.models import Trainer, OrganizationTrainerLink
from apps.customers.models import Customer, CustomerMembership
from django.contrib.auth import get_user_model

User = get_user_model()

print("--- USERS ---")
for u in User.objects.all():
    print(f"User ID: {u.id}, Email: {u.email}, Groups: {[g.name for g in u.groups.all()]}")
    mentor_profile = getattr(u, 'mentor_profile', None)
    if mentor_profile:
        print(f"  MentorProfile ID: {mentor_profile.id}, Org: {mentor_profile.organization}, Designation: {mentor_profile.designation}")
        # Let's check organizations where this mentor profile is the main mentor
        owned_orgs = Organization.objects.filter(mentor=mentor_profile)
        print(f"  Owned Orgs: {[o.name for o in owned_orgs]}")

print("\n--- ORGANIZATIONS ---")
for org in Organization.objects.all():
    print(f"Org ID: {org.id}, Name: {org.name}, Mentor: {org.mentor}")

print("\n--- TRAINERS ---")
for t in Trainer.objects.all():
    print(f"Trainer ID: {t.id}, Name: {t.full_name}, User: {t.user}")
