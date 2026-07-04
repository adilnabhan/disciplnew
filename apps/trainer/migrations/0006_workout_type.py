from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('trainer', '0005_workoutplanexercise_video_url'),
    ]

    operations = [
        migrations.AddField(
            model_name='workout',
            name='type',
            field=models.CharField(
                max_length=20,
                null=True,
                blank=True,
                choices=[
                    ('strength', 'Strength'),
                    ('cardio', 'Cardio'),
                    ('flexibility', 'Flexibility'),
                    ('balance', 'Balance'),
                    ('hiit', 'HIIT'),
                    ('other', 'Other'),
                ]
            ),
        ),
    ]
