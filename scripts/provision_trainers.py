
import os
import sys
import django

# Add current directory to path
sys.path.append(os.getcwd())

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from apps.user.models import User
from apps.trainer.models import Trainer

def provision():
    # Role 35: MENTOR_TRAINER, Role 36: MENTOR_DIETITIAN
    users = User.objects.filter(user_role__in=[35, 36])
    print(f"Found {users.count()} users with trainer/dietitian roles.")
    
    created_count = 0
    already_exists_count = 0
    
    for user in users:
        trainer, created = Trainer.objects.get_or_create(
            user=user,
            defaults={
                'first_name': user.first_name or 'Trainer',
                'last_name': user.last_name or '',
                'email': user.email,
                'mobile': str(user.mobile_number),
                'user_type': 'trainer' if user.user_role == 35 else 'dietitian'
            }
        )
        if created:
            created_count += 1
            print(f"Created profile for User ID: {user.id} ({user.first_name})")
        else:
            already_exists_count += 1
            
    print(f"Provisioning complete. Created: {created_count}, Already existed: {already_exists_count}")

if __name__ == "__main__":
    provision()
