import os
import sys
import django

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from django.test import RequestFactory
from django.contrib.auth import get_user_model
from apps.customers.models import Customer
from apps.customers.api.workout_views import StartWorkoutSessionView, FinishWorkoutSessionView
from apps.trainer.workout_models import WorkoutPlan, WorkoutPlanDay, WorkoutPlanExercise, Workout, WorkoutSession, CustomerWorkoutPlan
from rest_framework.test import force_authenticate
from django.utils import timezone

User = get_user_model()
user, _ = User.objects.get_or_create(username='finish_test_user', email='finish_test@example.com')
if not hasattr(user, 'customer'):
    customer = Customer.objects.create(user=user)
else:
    customer = user.customer

# Ensure clean state
WorkoutSession.objects.filter(customer=customer).delete()
CustomerWorkoutPlan.objects.filter(customer=customer).delete()
WorkoutPlan.objects.filter(customer=customer).delete()

workout, _ = Workout.objects.get_or_create(name="Barbell Bench Press", defaults={'status': True})

# Test Case 1: Finish session with save_as_preset=False -> Must remain as draft plan
print("\n=== TEST CASE 1: FINISH WITH SAVE_AS_PRESET = FALSE ===")
factory = RequestFactory()

start_req = factory.post('/api/v1/customer/sessions/start/', {'title': 'Draft Workout Session'}, content_type='application/json')
force_authenticate(start_req, user=user)
start_resp = StartWorkoutSessionView.as_view()(start_req)
session_id = start_resp.data['id']
session_obj = WorkoutSession.objects.get(pk=session_id)
orig_plan_id = session_obj.plan_day.plan.id

finish_data = {
    "title": "My Finished Session",
    "save_as_preset": False
}
finish_req = factory.post(f'/api/v1/customer/sessions/{session_id}/finish/', finish_data, content_type='application/json')
force_authenticate(finish_req, user=user)
finish_resp = FinishWorkoutSessionView.as_view()(finish_req, session_id=session_id)
print("Finish Session Response:", finish_resp.data)

orig_plan = WorkoutPlan.objects.get(pk=orig_plan_id)
print("Original Plan ID:", orig_plan.id)
print("Original Plan Name:", orig_plan.plan_name)
print("Original Plan Status:", orig_plan.status)
print("Original Plan Description:", orig_plan.description)


# Test Case 2: Finish session with save_as_preset=True -> Original must be set to status=False (deactivated)
print("\n=== TEST CASE 2: FINISH WITH SAVE_AS_PRESET = TRUE ===")
WorkoutSession.objects.filter(customer=customer).delete()
CustomerWorkoutPlan.objects.filter(customer=customer).delete()
WorkoutPlan.objects.filter(customer=customer).delete()

start_req = factory.post('/api/v1/customer/sessions/start/', {'title': 'Preset Base Session'}, content_type='application/json')
force_authenticate(start_req, user=user)
start_resp = StartWorkoutSessionView.as_view()(start_req)
session_id = start_resp.data['id']
session_obj = WorkoutSession.objects.get(pk=session_id)
orig_plan_id = session_obj.plan_day.plan.id

finish_data = {
    "title": "My New Preset Title",
    "save_as_preset": True
}
finish_req = factory.post(f'/api/v1/customer/sessions/{session_id}/finish/', finish_data, content_type='application/json')
force_authenticate(finish_req, user=user)
finish_resp = FinishWorkoutSessionView.as_view()(finish_req, session_id=session_id)
print("Finish Session Response:", finish_resp.data)

orig_plan = WorkoutPlan.objects.get(pk=orig_plan_id)
print("Original Plan ID:", orig_plan.id)
print("Original Plan Name (Should be updated):", orig_plan.plan_name)
print("Original Plan Status (Should be False):", orig_plan.status)

new_preset = WorkoutPlan.objects.get(pk=finish_resp.data['preset_id'])
print("New Preset ID:", new_preset.id)
print("New Preset Name:", new_preset.plan_name)
print("New Preset Status (Should be True):", new_preset.status)
print("New Preset Is Preset (Should be True):", new_preset.is_preset)

# Clean up
WorkoutSession.objects.filter(customer=customer).delete()
CustomerWorkoutPlan.objects.filter(customer=customer).delete()
WorkoutPlan.objects.filter(customer=customer).delete()
print("\nAll Test Cases Completed!")
