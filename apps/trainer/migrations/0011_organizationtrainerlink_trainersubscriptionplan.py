from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('trainer', '0010_location_country_blank'),
        ('fitnesscenter', '0014_add_pan_and_dob_fields'),
    ]

    operations = [
        migrations.CreateModel(
            name='TrainerSubscriptionPlan',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False)),
                ('name', models.CharField(max_length=100)),
                ('plan_type', models.CharField(max_length=20)),
                ('regular_price', models.DecimalField(decimal_places=2, max_digits=10)),
                ('discounted_price', models.DecimalField(decimal_places=2, max_digits=10)),
                ('total_cost', models.DecimalField(blank=True, decimal_places=2, max_digits=10, null=True)),
                ('savings', models.DecimalField(blank=True, decimal_places=2, max_digits=10, null=True)),
                ('period', models.PositiveIntegerField()),
                ('description', models.TextField(blank=True)),
                ('features', models.JSONField(blank=True, default=list, null=True)),
                ('is_active', models.BooleanField(default=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
            ],
        ),
        migrations.RunSQL(
            # Safe table creation - handles if table already exists
            sql="""
            DO $$ BEGIN
                CREATE TABLE IF NOT EXISTS trainer_organizationtrainerlink (
                    id bigserial PRIMARY KEY,
                    status varchar(10) NOT NULL DEFAULT 'pending',
                    requested_at timestamptz NOT NULL DEFAULT now(),
                    responded_at timestamptz,
                    rejection_reason text,
                    organization_id integer NOT NULL REFERENCES fitnesscenter_organization(id) ON DELETE CASCADE,
                    trainer_id bigint NOT NULL REFERENCES trainer_trainer(id) ON DELETE CASCADE,
                    UNIQUE (trainer_id, organization_id)
                );
            EXCEPTION WHEN duplicate_table THEN null;
            END $$;
            """,
            reverse_sql="DROP TABLE IF EXISTS trainer_organizationtrainerlink;",
        ),
        # Make Django aware of the model without recreating the table
        migrations.SeparateDatabaseAndState(
            state_operations=[
                migrations.CreateModel(
                    name='OrganizationTrainerLink',
                    fields=[
                        ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False)),
                        ('status', models.CharField(choices=[('pending', 'Pending'), ('approved', 'Approved'), ('rejected', 'Rejected')], default='pending', max_length=10)),
                        ('requested_at', models.DateTimeField(auto_now_add=True)),
                        ('responded_at', models.DateTimeField(blank=True, null=True)),
                        ('rejection_reason', models.TextField(blank=True, null=True)),
                        ('organization', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='trainer_links', to='fitnesscenter.organization')),
                        ('trainer', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='organization_links', to='trainer.trainer')),
                    ],
                    options={
                        'unique_together': {('trainer', 'organization')},
                    },
                ),
            ],
            database_operations=[],  # Table already exists, don't do database operations
        ),
    ]
