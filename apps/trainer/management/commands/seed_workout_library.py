from django.core.management.base import BaseCommand
from apps.trainer.workout_models import (
    MuscleGroup, Equipment, Workout, WorkoutMuscle,
    GymWorkoutOverride, ProgramGoal, DifficultyLevel,
)


class Command(BaseCommand):
    help = 'Seed workout library with exercises and create gym overrides for a given organization'

    def add_arguments(self, parser):
        parser.add_argument('--org_id', type=int, default=23, help='Organization ID to create overrides for')

    def handle(self, *args, **options):
        org_id = options['org_id']

        # Ensure muscle groups and equipment exist
        self._seed_muscle_groups()
        self._seed_equipment()
        self._seed_goals_and_levels()

        # Seed master exercises
        exercises = self._seed_exercises()

        # Create gym overrides for the given org
        self._seed_gym_overrides(org_id, exercises)

        self.stdout.write(self.style.SUCCESS(
            f'Seeded {len(exercises)} exercises with gym overrides for org {org_id}'
        ))

    def _seed_muscle_groups(self):
        names = [
            'Chest', 'Back', 'Shoulders', 'Biceps', 'Triceps', 'Forearms',
            'Quadriceps', 'Hamstrings', 'Calves', 'Glutes', 'Abs', 'Obliques',
            'Trapezius', 'Lats', 'Rear Delts', 'Hip Flexors', 'Lower Back',
        ]
        for n in names:
            MuscleGroup.objects.get_or_create(name=n, defaults={'status': True})

    def _seed_equipment(self):
        names = [
            'Barbell', 'Dumbbell', 'Kettlebell', 'Cable Machine', 'Smith Machine',
            'Bench', 'Pull-up Bar', 'Leg Press', 'Bodyweight', 'Resistance Band',
            'EZ Bar', 'Medicine Ball', 'Treadmill', 'Rowing Machine',
        ]
        for n in names:
            Equipment.objects.get_or_create(name=n, defaults={'status': True})

    def _seed_goals_and_levels(self):
        for g in ['Muscle Building', 'Fat Loss', 'Strength', 'Endurance', 'Flexibility', 'General Fitness']:
            ProgramGoal.objects.get_or_create(name=g, defaults={'status': True})
        for d in ['Beginner', 'Intermediate', 'Advanced', 'Elite']:
            DifficultyLevel.objects.get_or_create(name=d, defaults={'status': True})

    def _seed_exercises(self):
        """Seed master-level exercises (created_by=None = global)."""
        exercise_data = [
            # Chest
            {'name': 'Barbell Bench Press', 'type': 'strength', 'muscle': 'Chest', 'equip': 'Barbell',
             'desc': 'Compound chest exercise targeting pectorals, front delts, and triceps.',
             'instructions': '1. Lie flat on bench\n2. Grip barbell slightly wider than shoulders\n3. Lower to chest\n4. Press up to lockout'},
            {'name': 'Incline Dumbbell Press', 'type': 'strength', 'muscle': 'Chest', 'equip': 'Dumbbell',
             'desc': 'Targets upper chest with incline angle.',
             'instructions': '1. Set bench to 30-45 degrees\n2. Press dumbbells from chest to full extension'},
            {'name': 'Cable Chest Fly', 'type': 'strength', 'muscle': 'Chest', 'equip': 'Cable Machine',
             'desc': 'Isolation exercise for chest with constant cable tension.',
             'instructions': '1. Set cables at shoulder height\n2. Step forward\n3. Bring handles together in arc motion'},
            {'name': 'Push-ups', 'type': 'strength', 'muscle': 'Chest', 'equip': 'Bodyweight',
             'desc': 'Classic bodyweight chest exercise.', 'instructions': 'Standard push-up from toes or knees.'},
            # Back
            {'name': 'Barbell Deadlift', 'type': 'strength', 'muscle': 'Back', 'equip': 'Barbell',
             'desc': 'Full-body compound lift emphasizing posterior chain.',
             'instructions': '1. Stand with feet hip-width\n2. Hinge at hips\n3. Grip bar\n4. Drive through heels to stand'},
            {'name': 'Lat Pulldown', 'type': 'strength', 'muscle': 'Lats', 'equip': 'Cable Machine',
             'desc': 'Targets latissimus dorsi for back width.',
             'instructions': '1. Grip bar wide\n2. Pull to upper chest\n3. Squeeze lats\n4. Control return'},
            {'name': 'Barbell Bent-Over Row', 'type': 'strength', 'muscle': 'Back', 'equip': 'Barbell',
             'desc': 'Compound back thickness exercise.',
             'instructions': '1. Bend at hips ~45 degrees\n2. Pull barbell to lower chest\n3. Squeeze back'},
            {'name': 'Pull-ups', 'type': 'strength', 'muscle': 'Lats', 'equip': 'Pull-up Bar',
             'desc': 'Bodyweight lat exercise.', 'instructions': 'Overhand grip, pull chin above bar.'},
            # Shoulders
            {'name': 'Overhead Press', 'type': 'strength', 'muscle': 'Shoulders', 'equip': 'Barbell',
             'desc': 'Standing barbell press for overall shoulder development.',
             'instructions': '1. Grip at shoulder width\n2. Press overhead to lockout\n3. Lower under control'},
            {'name': 'Lateral Raises', 'type': 'strength', 'muscle': 'Shoulders', 'equip': 'Dumbbell',
             'desc': 'Isolation for medial deltoids.',
             'instructions': '1. Arms at sides\n2. Raise to shoulder height\n3. Control the descent'},
            # Legs
            {'name': 'Barbell Back Squat', 'type': 'strength', 'muscle': 'Quadriceps', 'equip': 'Barbell',
             'desc': 'King of leg exercises targeting quads, glutes, and hamstrings.',
             'instructions': '1. Bar on upper traps\n2. Squat to parallel or below\n3. Drive up through heels'},
            {'name': 'Romanian Deadlift', 'type': 'strength', 'muscle': 'Hamstrings', 'equip': 'Barbell',
             'desc': 'Hip hinge targeting hamstrings and glutes.',
             'instructions': '1. Hold barbell at hips\n2. Hinge forward keeping legs almost straight\n3. Feel hamstring stretch'},
            {'name': 'Leg Press', 'type': 'strength', 'muscle': 'Quadriceps', 'equip': 'Leg Press',
             'desc': 'Machine-based quad exercise with heavy loading potential.',
             'instructions': '1. Feet shoulder-width on platform\n2. Lower sled to 90 degrees\n3. Press back up'},
            {'name': 'Walking Lunges', 'type': 'strength', 'muscle': 'Glutes', 'equip': 'Dumbbell',
             'desc': 'Unilateral leg exercise for balance and strength.',
             'instructions': 'Step forward into lunge, alternate legs.'},
            {'name': 'Calf Raises', 'type': 'strength', 'muscle': 'Calves', 'equip': 'Smith Machine',
             'desc': 'Isolation for gastrocnemius.', 'instructions': 'Rise onto toes, pause at top, lower slowly.'},
            # Arms
            {'name': 'Barbell Bicep Curl', 'type': 'strength', 'muscle': 'Biceps', 'equip': 'EZ Bar',
             'desc': 'Classic bicep isolation.', 'instructions': 'Curl bar from thighs to chest, no swinging.'},
            {'name': 'Tricep Rope Pushdown', 'type': 'strength', 'muscle': 'Triceps', 'equip': 'Cable Machine',
             'desc': 'Cable isolation for triceps.',
             'instructions': '1. Grip rope at high cable\n2. Push down to full extension\n3. Spread rope at bottom'},
            {'name': 'Hammer Curls', 'type': 'strength', 'muscle': 'Biceps', 'equip': 'Dumbbell',
             'desc': 'Neutral grip curl for brachialis and forearms.',
             'instructions': 'Curl with palms facing each other.'},
            # Core
            {'name': 'Plank', 'type': 'strength', 'muscle': 'Abs', 'equip': 'Bodyweight',
             'desc': 'Isometric core stabilization.', 'instructions': 'Hold forearm plank position, engage core.'},
            {'name': 'Cable Woodchop', 'type': 'strength', 'muscle': 'Obliques', 'equip': 'Cable Machine',
             'desc': 'Rotational core exercise.', 'instructions': 'Pull cable diagonally across body with rotation.'},
            # Cardio
            {'name': 'Treadmill Running', 'type': 'cardio', 'muscle': 'Quadriceps', 'equip': 'Treadmill',
             'desc': 'Cardiovascular endurance training.', 'instructions': 'Maintain steady pace, adjust incline as needed.'},
            {'name': 'Rowing Machine', 'type': 'cardio', 'muscle': 'Back', 'equip': 'Rowing Machine',
             'desc': 'Full-body cardio with emphasis on back and legs.',
             'instructions': 'Drive with legs first, then pull with arms, control the return.'},
            {'name': 'Burpees', 'type': 'hiit', 'muscle': 'Abs', 'equip': 'Bodyweight',
             'desc': 'Full-body HIIT exercise.', 'instructions': 'Squat, jump back to plank, push-up, jump up.'},
            {'name': 'Kettlebell Swing', 'type': 'hiit', 'muscle': 'Glutes', 'equip': 'Kettlebell',
             'desc': 'Hip hinge power movement.',
             'instructions': '1. Hinge at hips\n2. Swing kettlebell to chest height using hip drive'},
        ]

        created = []
        for ex in exercise_data:
            muscle = MuscleGroup.objects.filter(name=ex['muscle']).first()
            equip = Equipment.objects.filter(name=ex['equip']).first()
            workout, _ = Workout.objects.get_or_create(
                name=ex['name'],
                created_by=None,  # global master exercise
                defaults={
                    'type': ex['type'],
                    'primary_muscle_group': muscle,
                    'equipment': equip,
                    'description': ex['desc'],
                    'instructions': ex['instructions'],
                    'status': True,
                }
            )
            created.append(workout)
        return created

    def _seed_gym_overrides(self, org_id, exercises):
        """Create GymWorkoutOverride for the given org so workout-library API returns data."""
        from apps.fitnesscenter.models import Organization
        try:
            org = Organization.objects.get(id=org_id)
        except Organization.DoesNotExist:
            self.stdout.write(self.style.WARNING(f'Organization {org_id} not found, skipping overrides'))
            return

        for workout in exercises:
            GymWorkoutOverride.objects.get_or_create(
                workout=workout,
                organization=org,
                defaults={
                    'video_url': None,
                    'instructions': None,
                    'is_visible': True,
                }
            )
