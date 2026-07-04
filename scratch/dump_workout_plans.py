import os
import sys
import django

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from apps.trainer.workout_models import WorkoutPlan

print("=== ALL WORKOUT PLANS IN DATABASE ===")
plans = WorkoutPlan.objects.all().order_by('id')
for p in plans:
    print(f"ID: {p.id} | Name: {p.plan_name} | status: {p.status} | is_preset: {p.is_preset} | customer: {p.customer_id if p.customer else 'None'} | description: {p.description}")
