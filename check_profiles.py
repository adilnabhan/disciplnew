
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from apps.user.models import User
from apps.trainer.models import Trainer

user = User.objects.filter(id=5).first()
print(f"User: {user}")
if user:
    trainer = Trainer.objects.filter(user=user).first()
    print(f"Trainer for User 5: {trainer}")
    if trainer:
         print(f"Trainer ID: {trainer.id}, User ID: {trainer.user_id}, User Type: {trainer.user_type}")
    
    # Check all trainers
    print("\nAll Trainers:")
    for t in Trainer.objects.all():
        print(f"Trainer ID: {t.id}, User ID: {t.user_id}, User Mobile: {t.user.mobile_number if t.user else 'No User'}")

