from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('trainer', '0008_trainer_mobile_email_nullable'),
    ]

    operations = [
        migrations.AlterField(
            model_name='trainersociallink',
            name='website',
            field=models.CharField(max_length=255, blank=True, null=True, default=''),
        ),
        migrations.AlterField(
            model_name='trainersociallink',
            name='whatsapp',
            field=models.CharField(max_length=20, blank=True, null=True, default=''),
        ),
        migrations.AlterField(
            model_name='trainersociallink',
            name='instagram',
            field=models.CharField(max_length=255, blank=True, null=True, default=''),
        ),
        migrations.AlterField(
            model_name='trainersociallink',
            name='facebook',
            field=models.CharField(max_length=255, blank=True, null=True, default=''),
        ),
        migrations.AlterField(
            model_name='trainersociallink',
            name='youtube',
            field=models.CharField(max_length=255, blank=True, null=True, default=''),
        ),
    ]
