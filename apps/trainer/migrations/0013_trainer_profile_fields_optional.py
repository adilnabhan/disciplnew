
import django.db.models.deletion
from django.db import migrations, models

class Migration(migrations.Migration):

    dependencies = [
        ('fitnesscenter', '0017_organizationtimeslot'),
        ('trainer', '0012_trainersubscription'),
    ]

    operations = [
        migrations.AlterField(
            model_name='trainer',
            name='date_of_birth',
            field=models.DateField(blank=True, null=True),
        ),
        migrations.AlterField(
            model_name='trainer',
            name='gender',
            field=models.CharField(blank=True, choices=[('male', 'Male'), ('female', 'Female'), ('other', 'Other')], max_length=10, null=True),
        ),
        migrations.AlterField(
            model_name='trainer',
            name='profile_image',
            field=models.ImageField(blank=True, null=True, upload_to='trainers/profile/'),
        ),
    ]
