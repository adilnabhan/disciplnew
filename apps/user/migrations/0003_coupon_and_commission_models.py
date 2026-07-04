from django.db import migrations, models
import django.db.models.deletion
from django.conf import settings


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('user', '0002_user_is_guest'),
        ('subscription', '0001_initial'),
    ]

    operations = [

        # --------------------------------------------------
        # 1️⃣ SalesExecutive
        # --------------------------------------------------
        migrations.CreateModel(
            name='SalesExecutive',
            fields=[
                ('id', models.BigAutoField(
                    auto_created=True,
                    primary_key=True,
                    serialize=False,
                    verbose_name='ID'
                )),
                ('name', models.CharField(max_length=150)),
                ('phone', models.CharField(
                    max_length=15,
                    blank=True,
                    null=True
                )),
                ('email', models.EmailField(
                    max_length=254,
                    blank=True,
                    null=True
                )),
                ('is_active', models.BooleanField(default=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
            ],
        ),

        # --------------------------------------------------
        # 2️⃣ Coupon
        # --------------------------------------------------
        migrations.CreateModel(
            name='Coupon',
            fields=[
                ('id', models.BigAutoField(
                    auto_created=True,
                    primary_key=True,
                    serialize=False,
                    verbose_name='ID'
                )),
                ('code', models.CharField(
                    max_length=50,
                    unique=True
                )),
                ('discount_type', models.CharField(
                    choices=[
                        ('percentage', 'Percentage'),
                        ('fixed', 'Fixed Amount')
                    ],
                    max_length=20
                )),
                ('discount_value', models.DecimalField(
                    max_digits=10,
                    decimal_places=2
                )),
                ('share_type', models.CharField(
                    choices=[
                        ('percentage', 'Percentage'),
                        ('fixed', 'Fixed Amount')
                    ],
                    default='percentage',
                    max_length=20
                )),
                ('share_value', models.DecimalField(
                    max_digits=10,
                    decimal_places=2
                )),
                ('max_usage', models.PositiveIntegerField(
                    null=True,
                    blank=True
                )),
                ('used_count', models.PositiveIntegerField(default=0)),
                ('valid_from', models.DateTimeField()),
                ('valid_to', models.DateTimeField()),
                ('is_active', models.BooleanField(default=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('sales_executive', models.ForeignKey(
                    to='user.salesexecutive',
                    on_delete=django.db.models.deletion.SET_NULL,
                    null=True,
                    blank=True,
                    related_name='coupons'
                )),
            ],
        ),

        # --------------------------------------------------
        # 3️⃣ SubscriptionTransaction
        # --------------------------------------------------
        migrations.CreateModel(
            name='SubscriptionTransaction',
            fields=[
                ('id', models.BigAutoField(
                    auto_created=True,
                    primary_key=True,
                    serialize=False,
                    verbose_name='ID'
                )),
                ('original_amount', models.DecimalField(
                    max_digits=10,
                    decimal_places=2
                )),
                ('discount_amount', models.DecimalField(
                    max_digits=10,
                    decimal_places=2
                )),
                ('final_amount', models.DecimalField(
                    max_digits=10,
                    decimal_places=2
                )),
                ('executive_commission', models.DecimalField(
                    max_digits=10,
                    decimal_places=2,
                    default=0
                )),
                ('commission_paid', models.BooleanField(default=False)),
                ('commission_paid_date', models.DateTimeField(
                    null=True,
                    blank=True
                )),
                ('payment_reference', models.CharField(
                    max_length=150,
                    blank=True,
                    null=True
                )),
                ('created_at', models.DateTimeField(auto_now_add=True)),

                ('coupon', models.ForeignKey(
                    to='user.coupon',
                    on_delete=django.db.models.deletion.SET_NULL,
                    null=True,
                    blank=True
                )),
                ('sales_executive', models.ForeignKey(
                    to='user.salesexecutive',
                    on_delete=django.db.models.deletion.SET_NULL,
                    null=True,
                    blank=True
                )),
                ('user', models.ForeignKey(
                    to=settings.AUTH_USER_MODEL,
                    on_delete=django.db.models.deletion.CASCADE
                )),
                ('plan', models.ForeignKey(
                    to='subscription.disciplsubscriptionplan',
                    on_delete=django.db.models.deletion.CASCADE
                )),
            ],
        ),
    ]