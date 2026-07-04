from django.core.management.base import BaseCommand
from apps.trainer.workout_models import MuscleGroup, Equipment


class Command(BaseCommand):
    help = 'Populate initial workout data (muscle groups and equipment)'

    def handle(self, *args, **options):
        # Muscle Groups
        muscle_groups = [
            'Chest (Pectoralis Major)',
            'Upper Chest',
            'Lower Chest',
            'Back (Latissimus Dorsi)',
            'Shoulders (Deltoids)',
            'Biceps (Biceps Brachii)',
            'Triceps (Triceps Brachii)',
            'Forearms',
            'Quadriceps (Quads)',
            'Hamstrings',
            'Calves (Gastrocnemius)',
            'Glutes (Gluteus Maximus)',
            'Abdominals (Rectus Abdominis)',
            'Obliques',
            'Trapezius',
            'Rhomboids',
            'Rear Deltoids',
            'Serratus Anterior',
            'Pectoralis Minor',
            'Soleus',
            'Tibialis Anterior',
        ]

        for name in muscle_groups:
            MuscleGroup.objects.get_or_create(name=name, defaults={'status': True})

        # Equipment
        equipment_list = [
            'Barbell',
            'Dumbbell',
            'Kettlebell',
            'Resistance Band',
            'Cable Machine',
            'Smith Machine',
            'Bench',
            'Pull-up Bar',
            'Dip Station',
            'Leg Press Machine',
            'Treadmill',
            'Elliptical',
            'Stationary Bike',
            'Rowing Machine',
            'Bodyweight',
            'Medicine Ball',
            'Foam Roller',
            'Yoga Mat',
            'Battle Ropes',
            'Box Jump Platform',
        ]

        for name in equipment_list:
            Equipment.objects.get_or_create(name=name, defaults={'status': True})

        self.stdout.write(
            self.style.SUCCESS('Successfully populated initial workout data')
        )