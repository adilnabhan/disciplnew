import os
import sys
import django

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from django.test import RequestFactory
from django.contrib.auth import get_user_model
from apps.customers.models import Customer
from apps.customers.api.workout_views import CustomerPresetListCreateView, CustomerPresetDetailView
from apps.trainer.workout_models import WorkoutPlan, Workout
from rest_framework.test import force_authenticate

User = get_user_model()

# Setup User and Customer
user, _ = User.objects.get_or_create(username='preset_test_user', email='preset_test@example.com')
if not hasattr(user, 'customer'):
    customer = Customer.objects.create(user=user)
else:
    customer = user.customer

# Ensure clean state
WorkoutPlan.objects.filter(customer=customer).delete()

# Ensure we have at least one workout/exercise in the system
workout, _ = Workout.objects.get_or_create(
    name="Barbell Bench Press",
    defaults={'status': True}
)

factory = RequestFactory()

# Test 1: Standard nested object creation
print("\n=== TEST 1: STANDARD NESTED CREATION ===")
data1 = {
    "title": "Standard Preset",
    "exercises": [
        {
            "workout_id": workout.id,
            "order_index": 1,
            "sets": [
                { "set_number": 1, "reps": 12, "weight": 40.0 }
            ]
        }
    ]
}
req1 = factory.post('/api/v1/customer/presets/', data1, content_type='application/json')
force_authenticate(req1, user=user)
resp1 = CustomerPresetListCreateView.as_view()(req1)
print("Create Status:", resp1.status_code)
print("Exercises Count:", len(resp1.data.get('exercises', [])))

# Test 2: Flat exercises list of IDs
print("\n=== TEST 2: FLAT EXERCISES LIST OF IDs ===")
data2 = {
    "title": "Flat Exercises Preset",
    "exercises": [workout.id]
}
req2 = factory.post('/api/v1/customer/presets/', data2, content_type='application/json')
force_authenticate(req2, user=user)
resp2 = CustomerPresetListCreateView.as_view()(req2)
print("Create Status:", resp2.status_code)
print("Exercises Count:", len(resp2.data.get('exercises', [])))

# Test 3: workout_ids format
print("\n=== TEST 3: WORKOUT IDS FORMAT ===")
data3 = {
    "title": "Workout IDs Preset",
    "workout_ids": [workout.id]
}
req3 = factory.post('/api/v1/customer/presets/', data3, content_type='application/json')
force_authenticate(req3, user=user)
resp3 = CustomerPresetListCreateView.as_view()(req3)
print("Create Status:", resp3.status_code)
print("Exercises Count:", len(resp3.data.get('exercises', [])))

# Cleanup
WorkoutPlan.objects.filter(customer=customer).delete()
print("\nAll preset tests completed successfully!")
