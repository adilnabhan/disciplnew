from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('trainer', '0004_workout_updates'),
    ]

    operations = [
        migrations.AddField(
            model_name='workoutplanexercise',
            name='video_url',
            field=models.CharField(max_length=500, null=True, blank=True),
        ),
    ]
