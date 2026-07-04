import os
import django
import sys

# Setup django environment
sys.path.append(os.getcwd())
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from apps.customers.api.workout_serializers import CustomerExerciseSetLogSerializer, CustomerSetTemplateSerializer

print("Testing CustomerExerciseSetLogSerializer with None values...")

class DummyExerciseSetLog:
    def __init__(self):
        self.id = 1
        self.set_number = 1
        self.reps = None
        self.weight_kg = None
        self.previous_weight_kg = None
        self.is_completed = False

dummy_log = DummyExerciseSetLog()
serializer_log = CustomerExerciseSetLogSerializer(dummy_log)
data_log = serializer_log.data
print("Serialized Log Data:", data_log)
assert data_log['reps'] is None, "reps should be None"
assert data_log['weight_kg'] is None, "weight_kg should be None"
assert data_log['previous_weight_kg'] is None, "previous_weight_kg should be None"

print("Testing CustomerSetTemplateSerializer with None values...")
class DummyExerciseSetTemplate:
    def __init__(self):
        self.id = 1
        self.set_number = 1
        self.target_reps = None
        self.target_weight = None
        self.rest_seconds = None

dummy_tmpl = DummyExerciseSetTemplate()
serializer_tmpl = CustomerSetTemplateSerializer(dummy_tmpl)
data_tmpl = serializer_tmpl.data
print("Serialized Template Data:", data_tmpl)
assert data_tmpl['target_reps'] is None, "target_reps should be None"
assert data_tmpl['target_weight'] is None, "target_weight should be None"
assert data_tmpl['rest_seconds'] == 60, "rest_seconds should default to 60"

print("ALL TESTS PASSED SUCCESSFULLY!")
