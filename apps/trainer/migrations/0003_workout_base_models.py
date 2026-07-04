from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('trainer', '0002_add_user_type'),
    ]

    operations = [

        migrations.CreateModel(
            name='MuscleGroup',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=150)),
                ('icon', models.CharField(max_length=255, null=True, blank=True)),
                ('status', models.BooleanField(default=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
        ),

        migrations.CreateModel(
            name='Equipment',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=150)),
                ('status', models.BooleanField(default=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
            ],
        ),

        migrations.CreateModel(
            name='ProgramGoal',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=150)),
                ('description', models.TextField(blank=True, null=True)),
                ('status', models.BooleanField(default=True)),
            ],
        ),

        migrations.CreateModel(
            name='DifficultyLevel',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=100)),
                ('description', models.TextField(blank=True, null=True)),
                ('status', models.BooleanField(default=True)),
            ],
        ),

        migrations.CreateModel(
            name='Workout',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=255)),
                ('description', models.TextField(blank=True, null=True)),
                ('video_url', models.CharField(max_length=500, null=True, blank=True)),
                ('thumbnail', models.ImageField(upload_to='workouts/thumbnails/', null=True, blank=True)),
                ('instructions', models.TextField(null=True, blank=True)),
                ('status', models.BooleanField(default=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('primary_muscle_group', models.ForeignKey(
                    on_delete=django.db.models.deletion.SET_NULL,
                    null=True, blank=True,
                    related_name='workouts',
                    to='trainer.musclegroup'
                )),
                ('equipment', models.ForeignKey(
                    on_delete=django.db.models.deletion.SET_NULL,
                    null=True, blank=True,
                    related_name='workouts',
                    to='trainer.equipment'
                )),
                ('created_by', models.ForeignKey(
                    on_delete=django.db.models.deletion.SET_NULL,
                    null=True, blank=True,
                    related_name='created_workouts',
                    to='user.user'
                )),
            ],
        ),

        migrations.CreateModel(
            name='WorkoutMuscle',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('workout', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='muscles',
                    to='trainer.workout'
                )),
                ('muscle_group', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='workout_muscles',
                    to='trainer.musclegroup'
                )),
            ],
        ),

        migrations.CreateModel(
            name='WorkoutPlan',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('plan_name', models.CharField(max_length=255)),
                ('description', models.TextField(blank=True, null=True)),
                ('total_weeks', models.IntegerField(default=1)),
                ('status', models.BooleanField(default=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('trainer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='workout_plans',
                    to='trainer.trainer'
                )),
                ('program_goal', models.ForeignKey(
                    on_delete=django.db.models.deletion.SET_NULL,
                    null=True, blank=True,
                    to='trainer.programgoal'
                )),
                ('difficulty_level', models.ForeignKey(
                    on_delete=django.db.models.deletion.SET_NULL,
                    null=True, blank=True,
                    to='trainer.difficultylevel'
                )),
            ],
        ),

        migrations.CreateModel(
            name='WorkoutPlanWeek',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('week_number', models.IntegerField()),
                ('title', models.CharField(max_length=255, blank=True, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('plan', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='weeks',
                    to='trainer.workoutplan'
                )),
            ],
        ),

        migrations.CreateModel(
            name='WorkoutPlanDay',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('day_number', models.IntegerField()),
                ('title', models.CharField(max_length=255, blank=True, null=True)),
                ('notes', models.TextField(blank=True, null=True)),
                ('week', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='days',
                    to='trainer.workoutplanweek'
                )),
            ],
        ),

        migrations.CreateModel(
            name='WorkoutPlanExercise',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('order_index', models.IntegerField(default=0)),
                ('notes', models.TextField(blank=True, null=True)),
                ('plan_day', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='exercises',
                    to='trainer.workoutplanday'
                )),
                ('workout', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='plan_exercises',
                    to='trainer.workout'
                )),
            ],
        ),

        migrations.CreateModel(
            name='ExerciseSetTemplate',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('set_number', models.IntegerField()),
                ('target_reps', models.IntegerField(null=True, blank=True)),
                ('target_weight', models.DecimalField(max_digits=6, decimal_places=2, null=True, blank=True)),
                ('rest_seconds', models.IntegerField(null=True, blank=True)),
                ('plan_exercise', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='sets',
                    to='trainer.workoutplanexercise'
                )),
            ],
        ),

        migrations.CreateModel(
            name='CustomerWorkoutPlan',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('start_date', models.DateField()),
                ('status', models.CharField(
                    max_length=20,
                    choices=[('active', 'Active'), ('completed', 'Completed'), ('cancelled', 'Cancelled')],
                    default='active'
                )),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('customer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='customer_workout_plans',
                    to='user.user'
                )),
                ('trainer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='assigned_workout_plans',
                    to='trainer.trainer'
                )),
                ('plan', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='customer_plans',
                    to='trainer.workoutplan'
                )),
            ],
        ),

        migrations.CreateModel(
            name='WorkoutSession',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('session_date', models.DateField()),
                ('status', models.CharField(
                    max_length=20,
                    choices=[
                        ('pending', 'Pending'),
                        ('in_progress', 'In Progress'),
                        ('completed', 'Completed'),
                        ('skipped', 'Skipped')
                    ],
                    default='pending'
                )),
                ('started_at', models.DateTimeField(null=True, blank=True)),
                ('completed_at', models.DateTimeField(null=True, blank=True)),
                ('customer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='workout_sessions',
                    to='user.user'
                )),
                ('plan_day', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='sessions',
                    to='trainer.workoutplanday'
                )),
            ],
        ),
    ]
