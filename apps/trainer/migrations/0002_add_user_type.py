from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('trainer', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='trainer',
            name='user_type',
            field=models.CharField(
                max_length=20,
                choices=[('trainer', 'Trainer'), ('dietitian', 'Dietitian')],
                default='trainer'
            ),
        ),
        migrations.AddField(
            model_name='specialization',
            name='user_type',
            field=models.CharField(
                max_length=20,
                choices=[('trainer', 'Trainer'), ('dietitian', 'Dietitian')],
                default='trainer'
            ),
        ),
    ]
