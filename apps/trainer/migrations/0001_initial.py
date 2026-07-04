from django.db import migrations, models
import django.db.models.deletion
class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('user', '0003_coupon_and_commission_models'),
    ]

    operations = [

        migrations.CreateModel(
            name='Trainer',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('user', models.OneToOneField(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='trainer_profile',
                    to='user.user',
                    null=True,
                    blank=True
                )),
                ('first_name', models.CharField(max_length=100)),
                ('last_name', models.CharField(max_length=100)),
                ('email', models.EmailField(max_length=150, unique=True)),
                ('mobile', models.CharField(max_length=20, unique=True)),
                ('gender', models.CharField(
                    max_length=10,
                    choices=[
                        ('male', 'Male'),
                        ('female', 'Female'),
                        ('other', 'Other')
                    ]
                )),
                ('date_of_birth', models.DateField()),
                ('profile_image', models.CharField(max_length=255, null=True, blank=True)),
                ('experience_years', models.IntegerField(default=0)),
                ('bio', models.TextField(blank=True)),
                ('is_freelancer', models.BooleanField(default=False)),
                ('join_gym', models.BooleanField(default=False)),
                ('event_collaborator', models.BooleanField(default=False)),
                ('expected_pay_min', models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)),
                ('expected_pay_max', models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)),
                ('profile_step', models.IntegerField(default=1)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
        ),

        migrations.CreateModel(
            name='TrainerExperience',
            fields=[
                (
                    'id',
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name='ID'
                    ),
                ),
                (
                    'organization_name',
                    models.CharField(max_length=255),
                ),
                (
                    'designation',
                    models.CharField(max_length=255),
                ),
                (
                    'start_date',
                    models.DateField(),
                ),
                (
                    'end_date',
                    models.DateField(null=True, blank=True),
                ),
                (
                    'currently_working',
                    models.BooleanField(default=False),
                ),
                (
                    'description',
                    models.TextField(null=True, blank=True),
                ),
                (
                    'created_at',
                    models.DateTimeField(auto_now_add=True),
                ),
                (
                    'trainer',
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name='experiences',
                        to='trainer.trainer',
                    ),
                ),
            ],
        ),

        migrations.CreateModel(
            name='Specialization',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=150)),
            ],
        ),

        migrations.CreateModel(
            name='TrainerSpecialization',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('trainer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    to='trainer.trainer'
                )),
                ('specialization', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    to='trainer.specialization'
                )),
            ],
        ),

        migrations.CreateModel(
            name='TrainerCertification',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('certificate_name', models.CharField(max_length=200)),
                ('certificate_file', models.CharField(max_length=255)),
                ('issued_by', models.CharField(max_length=200, blank=True)),
                ('issued_date', models.DateField(null=True, blank=True)),
                ('trainer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    to='trainer.trainer'
                )),
            ],
        ),

        migrations.CreateModel(
            name='TrainerPortfolio',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('image', models.CharField(max_length=255)),
                ('type', models.CharField(
                    max_length=20,
                    choices=[
                        ('result', 'Result'),
                        ('workout', 'Workout'),
                        ('achievement', 'Achievement')
                    ]
                )),
                ('trainer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    to='trainer.trainer'
                )),
            ],
        ),

        migrations.CreateModel(
            name='TrainerTransformation',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('before_image', models.CharField(max_length=255)),
                ('after_image', models.CharField(max_length=255)),
                ('description', models.TextField(blank=True)),
                ('trainer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    to='trainer.trainer'
                )),
            ],
        ),

        migrations.CreateModel(
            name='Language',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=100)),
            ],
        ),

        migrations.CreateModel(
            name='TrainerLanguage',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('trainer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    to='trainer.trainer'
                )),
                ('language', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    to='trainer.language'
                )),
            ],
        ),

        migrations.CreateModel(
            name='TrainerSocialLink',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('website', models.CharField(max_length=255, blank=True)),
                ('whatsapp', models.CharField(max_length=20, blank=True)),
                ('instagram', models.CharField(max_length=255, blank=True)),
                ('facebook', models.CharField(max_length=255, blank=True)),
                ('youtube', models.CharField(max_length=255, blank=True)),
                ('trainer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    to='trainer.trainer'
                )),
            ],
        ),

        migrations.CreateModel(
            name='Location',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('street', models.CharField(max_length=255)),
                ('area', models.CharField(max_length=255, blank=True, null=True)),
                ('city', models.CharField(max_length=100)),
                ('state', models.CharField(max_length=100)),
                ('country', models.CharField(max_length=100, default='India')),
                ('pincode', models.CharField(max_length=10)),
                ('latitude', models.DecimalField(max_digits=10, decimal_places=7, null=True, blank=True)),
                ('longitude', models.DecimalField(max_digits=10, decimal_places=7, null=True, blank=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('trainer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    to='trainer.trainer'
                )),
            ],
        ),

        migrations.CreateModel(
            name='TrainerBankAccount',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('account_holder_name', models.CharField(max_length=255)),
                ('account_number', models.CharField(max_length=50)),
                ('ifsc_code', models.CharField(max_length=20)),
                ('pan_number', models.CharField(blank=True, max_length=20, null=True)),
                ('business_type', models.CharField(default='individual', max_length=50)),
                ('razorpay_account_id', models.CharField(blank=True, max_length=100, null=True)),
                ('razorpay_product_id', models.CharField(blank=True, max_length=100, null=True)),
                ('razorpay_stakeholder_id', models.CharField(blank=True, max_length=100, null=True)),
                ('razorpay_account_status', models.CharField(default='verification_pending', max_length=50)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('trainer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='bank_accounts',
                    to='trainer.trainer'
                )),
            ],
        ),

        migrations.CreateModel(
            name='TrainerPlan',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('plan_name', models.CharField(max_length=255)),
                ('description', models.TextField(blank=True, null=True)),
                ('price', models.DecimalField(max_digits=10, decimal_places=2)),
                ('offer_price', models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)),
                ('duration_days', models.IntegerField()),
                ('emi_available', models.BooleanField(default=False)),
                ('max_clients', models.IntegerField(null=True, blank=True)),
                ('is_active', models.BooleanField(default=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('trainer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    to='trainer.trainer'
                )),
            ],
        ),

        migrations.CreateModel(
            name='TrainerLocationPreference',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('location_name', models.CharField(max_length=255)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('trainer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='location_preferences',
                    to='trainer.trainer'
                )),
            ],
        ),

        migrations.CreateModel(
            name='TrainerSubscription',
            fields=[
                ('id', models.BigAutoField(primary_key=True, serialize=False)),
                ('status', models.CharField(
                    max_length=20,
                    choices=[
                        ('Trial', 'Trial'),
                        ('Active', 'Active'),
                        ('Expired', 'Expired'),
                        ('Cancelled', 'Cancelled'),
                        ('Pending', 'Pending')
                    ],
                    default='PENDING'
                )),
                ('paid_amount', models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)),
                ('razorpay_order_id', models.CharField(max_length=255, null=True, blank=True)),
                ('razorpay_payment_id', models.CharField(max_length=255, null=True, blank=True)),
                ('start_date', models.DateTimeField(null=True, blank=True)),
                ('end_date', models.DateTimeField(null=True, blank=True)),
                ('payment_status', models.CharField(
                    max_length=20,
                    choices=[('pending', 'Pending'), ('completed', 'Completed'), ('failed', 'Failed')],
                    default='pending'
                )),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('trainer', models.ForeignKey(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='subscriptions',
                    to='trainer.trainer'
                )),
                ('plan', models.ForeignKey(
                    on_delete=django.db.models.deletion.PROTECT,
                    to='subscription.disciplsubscriptionplan'
                )),
            ],
        ),
    ]