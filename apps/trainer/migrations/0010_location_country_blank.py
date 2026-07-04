from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('trainer', '0009_trainersociallink_nullable'),
    ]

    operations = [
        migrations.AlterField(
            model_name='location',
            name='country',
            field=models.CharField(blank=True, default='India', max_length=100),
        ),
    ]
