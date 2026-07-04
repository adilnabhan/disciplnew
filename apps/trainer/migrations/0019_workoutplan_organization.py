from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('trainer', '0018_trainerreview'),
        ('trainer', '0017_workout_organization_library'),
        ('fitnesscenter', '0017_organizationtimeslot'),
    ]

    operations = [

        # Remove organization from Workout (wrong approach — use overrides instead)
        migrations.RemoveField(
            model_name='workout',
            name='organization',
        ),


        # Make WorkoutGroup.trainer nullable, add organization FK
        migrations.AlterField(
            model_name='workoutgroup',
            name='trainer',
            field=models.ForeignKey(
                blank=True, null=True,
                on_delete=django.db.models.deletion.CASCADE,
                related_name='workout_groups',
                to='trainer.trainer',
            ),
        ),
        migrations.AddField(
            model_name='workoutgroup',
            name='organization',
            field=models.ForeignKey(
                blank=True, null=True,
                on_delete=django.db.models.deletion.CASCADE,
                related_name='workout_groups',
                to='fitnesscenter.organization',
            ),
        ),

        # Make WorkoutPlan.trainer nullable, add organization FK
        migrations.AlterField(
            model_name='workoutplan',
            name='trainer',
            field=models.ForeignKey(
                blank=True, null=True,
                on_delete=django.db.models.deletion.CASCADE,
                related_name='workout_plans',
                to='trainer.trainer',
            ),
        ),
        migrations.AddField(
            model_name='workoutplan',
            name='organization',
            field=models.ForeignKey(
                blank=True, null=True,
                on_delete=django.db.models.deletion.CASCADE,
                related_name='workout_plans',
                to='fitnesscenter.organization',
            ),
        ),
    ]
