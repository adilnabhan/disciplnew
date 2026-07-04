from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('trainer', '0011_organizationtrainerlink_trainersubscriptionplan'),
    ]

    operations = [
        # Make Django aware of the model without recreating the table
        migrations.SeparateDatabaseAndState(
            state_operations=[
                migrations.CreateModel(
                    name='TrainerSubscription',
                    fields=[
                        ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False)),
                        ('paid_amount', models.DecimalField(decimal_places=2, max_digits=10, null=True, blank=True)),
                        ('razorpay_order_id', models.CharField(max_length=255, null=True, blank=True)),
                        ('razorpay_payment_id', models.CharField(max_length=255, null=True, blank=True)),
                        ('payment_status', models.CharField(default='pending', max_length=20)),
                        ('status', models.CharField(default='PENDING', max_length=20)),
                        ('start_date', models.DateTimeField(blank=True, null=True)),
                        ('end_date', models.DateTimeField(blank=True, null=True)),
                        ('created_at', models.DateTimeField(auto_now_add=True)),
                        ('updated_at', models.DateTimeField(auto_now=True)),
                        ('plan', models.ForeignKey(on_delete=django.db.models.deletion.RESTRICT, to='trainer.trainersubscriptionplan')),
                        ('trainer', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='trainer.trainer')),
                    ],
                ),
            ],
            database_operations=[],  # Table already exists, don't do database operations
        ),
    ]
