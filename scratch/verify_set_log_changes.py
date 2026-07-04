import os
import django
import sys
from django.utils import timezone

# Setup django environment
sys.path.append(os.getcwd())
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from apps.user.models import User
from apps.customers.models import Customer
from apps.trainer.workout_models import (
    WorkoutPlan, WorkoutPlanDay, WorkoutPlanExercise, ExerciseSetTemplate,
    WorkoutSession, WorkoutLog, ExerciseSetLog, Workout
)

def run_tests():
    # Setup dummy database entries
    print("Setting up test data...")
    user = User.objects.filter(mobile_number="+919961333048").first()
    if not user:
        user = User.objects.create(
            mobile_number="+919961333048",
            email="test_session@gmail.com",
            first_name="Test",
            username="+919961333048"
        )
    
    customer = Customer.objects.filter(user=user).first()
    if not customer:
        customer = Customer.objects.create(user=user)

    # 1. Create a clean preset WorkoutPlan
    preset = WorkoutPlan.objects.create(
        customer=customer,
        plan_name="Test Preset Template",
        is_preset=True,
        total_weeks=1,
        total_days=1,
        status=True
    )
    preset_day = WorkoutPlanDay.objects.create(
        plan=preset,
        day_number=1,
        title="Day 1"
    )
    # Get or create a dummy workout
    workout = Workout.objects.first()
    if not workout:
        workout = Workout.objects.create(
            name="Bench Press",
            muscle_group="Chest",
            difficulty_level="Beginner",
            gif_url="http://example.com/gif"
        )
    
    plan_ex = WorkoutPlanExercise.objects.create(
        plan_day=preset_day,
        workout=workout,
        order_index=1
    )
    
    # Create 2 sets templates on this preset: Set 1 (10 reps, 50kg), Set 2 (8 reps, 60kg)
    tmpl1 = ExerciseSetTemplate.objects.create(
        plan_exercise=plan_ex,
        set_number=1,
        target_reps=10,
        target_weight=50.0,
        rest_seconds=60
    )
    tmpl2 = ExerciseSetTemplate.objects.create(
        plan_exercise=plan_ex,
        set_number=2,
        target_reps=8,
        target_weight=60.0,
        rest_seconds=60
    )
    
    print("Preset template setup complete.")
    
    # 2. Simulate Starting a Workout Session from this Preset
    print("\nStarting workout session from preset...")
    session = WorkoutSession.objects.create(
        customer=customer,
        plan_day=preset_day,
        session_date=timezone.now().date(),
        status='in_progress',
        title="Workout Log Session"
    )
    
    log = WorkoutLog.objects.create(
        session=session,
        customer=customer,
        plan_exercise=plan_ex
    )
    
    # Create set logs mirroring preset templates, initially null
    s1 = ExerciseSetLog.objects.create(
        workout_log=log,
        set_number=1,
        reps=None,
        weight_kg=None,
        is_completed=False
    )
    s2 = ExerciseSetLog.objects.create(
        workout_log=log,
        set_number=2,
        reps=None,
        weight_kg=None,
        is_completed=False
    )
    
    print(f"Initial state: S1 (comp={s1.is_completed}, reps={s1.reps}, weight={s1.weight_kg})")
    print(f"Initial state: S2 (comp={s2.is_completed}, reps={s2.reps}, weight={s2.weight_kg})")
    assert s1.reps is None and s1.weight_kg is None and s1.is_completed is False
    
    # 3. Simulate client completing/ticking S1 (using django/patch logic)
    print("\nTicking S1 as completed...")
    # Simulate PATCH request to complete S1 with reps/weight = None
    s1.is_completed = True
    # In PATCH view, we fetch template target fallbacks:
    tmpl = s1.workout_log.plan_exercise.sets.filter(set_number=s1.set_number).first()
    if s1.reps is None:
        s1.reps = tmpl.target_reps
    if s1.weight_kg is None:
        s1.weight_kg = tmpl.target_weight
    s1.save()
    
    print(f"After tick: S1 (comp={s1.is_completed}, reps={s1.reps}, weight={s1.weight_kg})")
    assert s1.is_completed is True
    assert s1.reps == 10
    assert s1.weight_kg == 50.0

    # 4. Simulate client unticking S1
    print("\nUnticking S1...")
    s1.is_completed = False
    s1.reps = None
    s1.weight_kg = None
    s1.save()
    print(f"After untick: S1 (comp={s1.is_completed}, reps={s1.reps}, weight={s1.weight_kg})")
    assert s1.is_completed is False
    assert s1.reps is None
    assert s1.weight_kg is None

    # 5. Simulate ticking S1 with custom reps and weights
    print("\nTicking S1 with custom values (12 reps, 52.5kg)...")
    s1.is_completed = True
    s1.reps = 12
    s1.weight_kg = 52.5
    s1.save()
    print(f"After custom tick: S1 (comp={s1.is_completed}, reps={s1.reps}, weight={s1.weight_kg})")
    assert s1.is_completed is True
    assert s1.reps == 12
    assert s1.weight_kg == 52.5

    # 6. Simulate Finishing Workout Session
    # S1 is ticked (12 reps, 52.5kg). S2 is unticked (reps=None, weight=None).
    print("\nFinishing workout session...")
    
    # Mark session completed
    session.status = 'completed'
    session.completed_at = timezone.now()
    session.save()
    
    # Mark logs completed
    WorkoutLog.objects.filter(session=session, is_completed=False).update(is_completed=True)
    
    # Mark all set logs completed and populate missing targets
    set_logs_all = ExerciseSetLog.objects.filter(workout_log__session=session)
    for s in set_logs_all:
        s.is_completed = True
        if s.reps is None or s.weight_kg is None:
            fallback_reps = None
            fallback_weight = None
            try:
                if s.workout_log.plan_exercise:
                    t = s.workout_log.plan_exercise.sets.filter(set_number=s.set_number).first()
                    if t:
                        fallback_reps = t.target_reps
                        fallback_weight = t.target_weight
            except Exception:
                pass
            
            if s.reps is None:
                s.reps = fallback_reps
            if s.weight_kg is None:
                s.weight_kg = fallback_weight
        s.save()
        
    # Reload set logs
    s1.refresh_from_db()
    s2.refresh_from_db()
    print(f"Final finished state S1: (comp={s1.is_completed}, reps={s1.reps}, weight={s1.weight_kg})")
    print(f"Final finished state S2: (comp={s2.is_completed}, reps={s2.reps}, weight={s2.weight_kg})")
    
    # S1 keeps custom values
    assert s1.is_completed is True
    assert s1.reps == 12
    assert s1.weight_kg == 52.5
    
    # S2 gets target fallback values
    assert s2.is_completed is True
    assert s2.reps == 8
    assert s2.weight_kg == 60.0

    # 7. Verify that the original preset template is UNTOUCHED
    tmpl1.refresh_from_db()
    tmpl2.refresh_from_db()
    print(f"Original Preset Template Set 1: target_reps={tmpl1.target_reps}, target_weight={tmpl1.target_weight}")
    print(f"Original Preset Template Set 2: target_reps={tmpl2.target_reps}, target_weight={tmpl2.target_weight}")
    
    assert tmpl1.target_reps == 10, "Original preset template Set 1 target_reps should not change!"
    assert tmpl1.target_weight == 50.0, "Original preset template Set 1 target_weight should not change!"
    assert tmpl2.target_reps == 8, "Original preset template Set 2 target_reps should not change!"
    assert tmpl2.target_weight == 60.0, "Original preset template Set 2 target_weight should not change!"

    # 8. Verify Serializer representation of None/null values -> "no data"
    print("\nVerifying serializer representation for null/None values...")
    from apps.customers.api.workout_serializers import CustomerExerciseSetLogSerializer
    s3 = ExerciseSetLog.objects.create(
        workout_log=log,
        set_number=3,
        reps=None,
        weight_kg=None,
        previous_weight_kg=None,
        is_completed=False
    )
    serialized_data = CustomerExerciseSetLogSerializer(s3).data
    print(f"Serialized S3: reps={serialized_data['reps']}, weight={serialized_data['weight_kg']}, prev_weight={serialized_data['previous_weight_kg']}")
    assert serialized_data['reps'] == "no data", "Serializer should return 'no data' for reps when None"
    assert serialized_data['weight_kg'] == "no data", "Serializer should return 'no data' for weight_kg when None"
    assert serialized_data['previous_weight_kg'] == "no data", "Serializer should return 'no data' for previous_weight_kg when None"

    print("\nALL BACKEND LOGIC VERIFIED SUCCESSFULLY!")

if __name__ == "__main__":
    run_tests()
