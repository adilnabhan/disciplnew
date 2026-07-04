from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('trainer', '0016_fix_trainersubscription_plan_column'),
    ]

    operations = [
        migrations.AddField(
            model_name='organizationtrainerlink',
            name='invited_by_org',
            field=models.BooleanField(default=False, help_text='True if gym sent the invite, False if trainer requested'),
        ),
    ]
