from django.db import migrations, models


class Migration(migrations.Migration):

    atomic = False

    dependencies = [
        ('fitnesscenter', '0017_organizationtimeslot'),
    ]

    operations = [
        migrations.AddField(
            model_name='organization',
            name='registration_status',
            field=models.CharField(
                choices=[
                    ('unregistered', 'Unregistered'),
                    ('registered', 'Registered'),
                    ('verified', 'Verified'),
                ],
                db_index=True,
                default='unregistered',
                max_length=20,
            ),
        ),
        # Set existing orgs with mentor as registered
        migrations.RunSQL(
            sql="""
                UPDATE fitnesscenter_organization
                SET registration_status = 'registered'
                WHERE mentor_id IS NOT NULL;

                UPDATE fitnesscenter_organization o
                SET registration_status = 'verified'
                FROM fitnesscenter_bankaccountdetails b
                WHERE b.organization_id = o.id
                AND b.razorpay_account_status = 'Activated';
            """,
            reverse_sql=migrations.RunSQL.noop,
        ),
    ]
