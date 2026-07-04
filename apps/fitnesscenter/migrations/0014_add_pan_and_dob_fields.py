from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('fitnesscenter', '0013_bankaccountdetails_business_type'), 
    ]

    operations = [
        migrations.AddField(
            model_name='bankaccountdetails',
            name='pan_number',
            field=models.CharField(max_length=10, null=True, blank=True),
        ),
        migrations.AddField(
            model_name='bankaccountdetails',
            name='date_of_birth',
            field=models.DateField(null=True, blank=True),
        ),
        migrations.AddField(
            model_name='bankaccountdetails',
            name='razorpay_stakeholder_id',
            field=models.CharField(max_length=100, null=True, blank=True),
        ),
        migrations.AddField(
            model_name='bankaccountdetails',
            name='activated_at',
            field=models.DateTimeField(null=True, blank=True),
        ),
    ]