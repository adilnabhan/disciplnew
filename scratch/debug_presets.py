import os
import sys
import django

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from apps.trainer.workout_models import WorkoutPlan, WorkoutSession, WorkoutLog, ExerciseSetLog

print("=== WORKOUT PLANS ===")
for p in WorkoutPlan.objects.all().order_by('-id'):
    print(f"ID: {p.id} | Name: {p.plan_name} | Customer: {p.customer} | is_preset: {p.is_preset} | status: {p.status} | Created: {p.created_at}")

print("\n=== WORKOUT SESSIONS ===")
for s in WorkoutSession.objects.all().order_by('-id'):
    print(f"Session ID: {s.id} | Title: {s.title} | status: {s.status} | customer_workout_plan: {s.customer_workout_plan} | plan_day: {s.plan_day}")
