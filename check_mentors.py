import os, django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from apps.user.models import User

mentors = User.objects.filter(user_role=35)[:5]
print(f"Total mentor users: {User.objects.filter(user_role=35).count()}")
print("First 5 mentor users:")
for u in mentors:
    pw_ok = u.check_password("Password@123")
    print(f"  id={u.id} username='{u.username}' mobile={u.mobile_number} email={u.email} pw_ok={pw_ok}")

# Also check all users with any credentials
all_users = User.objects.all()[:5]
print(f"\nFirst 5 users overall:")
for u in all_users:
    pw_ok = u.check_password("Password@123")
    print(f"  id={u.id} username='{u.username}' role={u.user_role} mobile={u.mobile_number} pw_ok={pw_ok}")
