"""
Seed master exercises into the database.
Only creates if no exercises exist yet.
"""
from django.core.management.base import BaseCommand
from apps.trainer.workout_models import Workout, MuscleGroup, Equipment


EXERCISES = [
    {"name": "Barbell Bench Press", "type": "strength", "muscle": "Chest", "equipment": "Barbell"},
    {"name": "Incline Dumbbell Press", "type": "strength", "muscle": "Chest", "equipment": "Dumbbell"},
    {"name": "Cable Chest Fly", "type": "strength", "muscle": "Chest", "equipment": "Cable"},
    {"name": "Push-ups", "type": "strength", "muscle": "Chest", "equipment": None},
    {"name": "Barbell Deadlift", "type": "strength", "muscle": "Back", "equipment": "Barbell"},
    {"name": "Lat Pulldown", "type": "strength", "muscle": "Back", "equipment": "Cable"},
    {"name": "Barbell Bent-Over Row", "type": "strength", "muscle": "Back", "equipment": "Barbell"},
    {"name": "Pull-ups", "type": "strength", "muscle": "Back", "equipment": None},
    {"name": "Overhead Press", "type": "strength", "muscle": "Shoulders", "equipment": "Barbell"},
    {"name": "Lateral Raises", "type": "strength", "muscle": "Shoulders", "equipment": "Dumbbell"},
    {"name": "Barbell Squat", "type": "strength", "muscle": "Legs", "equipment": "Barbell"},
    {"name": "Leg Press", "type": "strength", "muscle": "Legs", "equipment": "Machine"},
    {"name": "Leg Curl", "type": "strength", "muscle": "Legs", "equipment": "Machine"},
    {"name": "Calf Raises", "type": "strength", "muscle": "Legs", "equipment": "Machine"},
    {"name": "Barbell Curl", "type": "strength", "muscle": "Biceps", "equipment": "Barbell"},
    {"name": "Dumbbell Curl", "type": "strength", "muscle": "Biceps", "equipment": "Dumbbell"},
    {"name": "Tricep Pushdown", "type": "strength", "muscle": "Triceps", "equipment": "Cable"},
    {"name": "Skull Crushers", "type": "strength", "muscle": "Triceps", "equipment": "Barbell"},
    {"name": "Plank", "type": "strength", "muscle": "Core", "equipment": None},
    {"name": "Crunches", "type": "strength", "muscle": "Core", "equipment": None},
    {"name": "Treadmill Running", "type": "cardio", "muscle": "Full Body", "equipment": "Machine"},
    {"name": "Jump Rope", "type": "cardio", "muscle": "Full Body", "equipment": None},
    {"name": "Burpees", "type": "hiit", "muscle": "Full Body", "equipment": None},
    {"name": "Mountain Climbers", "type": "hiit", "muscle": "Core", "equipment": None},
]


class Command(BaseCommand):
    help = "Seed master exercises if none exist"

    def handle(self, *args, **options):
        if Workout.objects.exists():
            self.stdout.write(self.style.WARNING(
                f"Skipping seed — {Workout.objects.count()} exercises already exist."
            ))
            return

        muscle_cache = {}
        equip_cache = {}

        for ex in EXERCISES:
            # Get or create muscle group
            mg = None
            if ex["muscle"]:
                if ex["muscle"] not in muscle_cache:
                    mg, _ = MuscleGroup.objects.get_or_create(name=ex["muscle"])
                    muscle_cache[ex["muscle"]] = mg
                mg = muscle_cache[ex["muscle"]]

            # Get or create equipment
            eq = None
            if ex["equipment"]:
                if ex["equipment"] not in equip_cache:
                    eq, _ = Equipment.objects.get_or_create(name=ex["equipment"])
                    equip_cache[ex["equipment"]] = eq
                eq = equip_cache[ex["equipment"]]

            Workout.objects.create(
                name=ex["name"],
                type=ex["type"],
                primary_muscle_group=mg,
                equipment=eq,
            )

        self.stdout.write(self.style.SUCCESS(
            f"Seeded {len(EXERCISES)} master exercises."
        ))
