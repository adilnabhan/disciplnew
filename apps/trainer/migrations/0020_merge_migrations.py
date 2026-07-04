from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('fitnesscenter', '0017_organizationtimeslot'),
        ('trainer', '0010_location_country_blank'),
        ('trainer', '0017_organizationtrainerlink_invited_by_org'),
        ('trainer', '0017_workout_organization_library'),
        ('trainer', '0018_trainerreview'),
        ('trainer', '0019_workoutplan_organization'),
    ]

    operations = [
        # GymWorkoutOverride and TrainerWorkoutOverride tables already exist in DB
        # (created manually or via 0019). Register model state only.
        migrations.SeparateDatabaseAndState(
            state_operations=[
                migrations.CreateModel(
                    name='GymWorkoutOverride',
                    fields=[
                        ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                        ('video_url', models.CharField(blank=True, max_length=500, null=True)),
                        ('instructions', models.TextField(blank=True, null=True)),
                        ('is_visible', models.BooleanField(default=True)),
                        ('created_at', models.DateTimeField(auto_now_add=True)),
                        ('updated_at', models.DateTimeField(auto_now=True)),
                        ('organization', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='workout_overrides', to='fitnesscenter.organization')),
                        ('workout', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='gym_overrides', to='trainer.workout')),
                    ],
                    options={'unique_together': {('workout', 'organization')}},
                ),
                migrations.CreateModel(
                    name='TrainerWorkoutOverride',
                    fields=[
                        ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                        ('video_url', models.CharField(blank=True, max_length=500, null=True)),
                        ('instructions', models.TextField(blank=True, null=True)),
                        ('created_at', models.DateTimeField(auto_now_add=True)),
                        ('updated_at', models.DateTimeField(auto_now=True)),
                        ('trainer', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='workout_overrides', to='trainer.trainer')),
                        ('workout', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='trainer_overrides', to='trainer.workout')),
                    ],
                    options={'unique_together': {('workout', 'trainer')}},
                ),
            ],
            database_operations=[],
        ),
    ]
