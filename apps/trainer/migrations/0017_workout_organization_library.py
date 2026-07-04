from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('trainer', '0016_fix_trainersubscription_plan_column'),
        ('fitnesscenter', '0017_organizationtimeslot'),
    ]

    operations = [
        migrations.AddField(
            model_name='workout',
            name='organization',
            field=models.ForeignKey(
                blank=True,
                null=True,
                on_delete=django.db.models.deletion.CASCADE,
                related_name='workout_library',
                to='fitnesscenter.organization',
            ),
        ),
    ]
