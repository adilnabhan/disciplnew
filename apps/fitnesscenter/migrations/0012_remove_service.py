# Generated migration to remove Service model

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('fitnesscenter', '0011_bankaccountdetails_razorpay_account_id_and_more'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='service',
            name='organization',
        ),
        migrations.DeleteModel(
            name='Service',
        ),
    ]
