from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('trainer', '0007_workout_log_updates'),
    ]

    operations = [
        migrations.AlterField(
            model_name='trainer',
            name='mobile',
            field=models.CharField(max_length=20, unique=True, null=True, blank=True),
        ),
        migrations.AlterField(
            model_name='trainer',
            name='email',
            field=models.EmailField(max_length=150, unique=True, null=True, blank=True),
        ),
    ]
