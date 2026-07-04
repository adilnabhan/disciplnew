import os
import sys
import django

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from apps.trainer.workout_models import WorkoutPlan

print("=== RECENT WORKOUT PLANS IN DATABASE ===")
plans = WorkoutPlan.objects.filter(id__gte=140).order_by('id')
for p in plans:
    cust_user = p.customer.user.email if (p.customer and p.customer.user) else "No User"
    cust = f"Customer(id={p.customer.id}, user={cust_user})" if p.customer else "None"
    print(f"ID: {p.id} | Name: {p.plan_name} | status: {p.status} | is_preset: {p.is_preset} | customer: {cust} | description: {p.description}")
