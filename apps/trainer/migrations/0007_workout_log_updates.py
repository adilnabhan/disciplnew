from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('trainer', '0006_workout_type'),
    ]

    operations = [

        migrations.AddField(
            model_name='workoutsession',
            name='customer_workout_plan',
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE,
                related_name='sessions',
                to='trainer.customerworkoutplan',
                null=True,
                blank=True,
            ),
        ),

        migrations.AddField(
            model_name='workoutlog',
            name='is_completed',
            field=models.BooleanField(default=False),
        ),

        migrations.AddField(
            model_name='exercisesetlog',
            name='is_completed',
            field=models.BooleanField(default=False),
        ),
    ]
