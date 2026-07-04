from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    atomic = False

    dependencies = [
        ('trainer', '0014_fix_trainersubscription_types'),
        ('customers', '0020_membershiprequest_accepted_amount_and_more'),
    ]

    operations = [

        # Drop all FK constraints on customer_id dynamically (unknown auto-generated names)
        migrations.RunSQL(
            sql="""
                DO $$
                DECLARE r RECORD;
                BEGIN
                    FOR r IN (
                        SELECT tc.constraint_name, tc.table_name
                        FROM information_schema.table_constraints tc
                        JOIN information_schema.key_column_usage kcu
                            ON tc.constraint_name = kcu.constraint_name
                            AND tc.table_schema = kcu.table_schema
                        WHERE tc.constraint_type = 'FOREIGN KEY'
                        AND kcu.column_name = 'customer_id'
                        AND tc.table_name IN (
                            'trainer_customerworkoutplan',
                            'trainer_workoutsession',
                            'trainer_workoutlog',
                            'trainer_prrecord'
                        )
                    ) LOOP
                        EXECUTE format('ALTER TABLE %I DROP CONSTRAINT %I', r.table_name, r.constraint_name);
                    END LOOP;
                END $$;
            """,
            reverse_sql=migrations.RunSQL.noop,
        ),

        # Now update existing data: replace user_id with customer_id
        migrations.RunSQL(
            sql="""
                UPDATE trainer_customerworkoutplan t
                    SET customer_id = c.id
                    FROM customers_customer c
                    WHERE c.user_id = t.customer_id;

                UPDATE trainer_workoutsession t
                    SET customer_id = c.id
                    FROM customers_customer c
                    WHERE c.user_id = t.customer_id;

                UPDATE trainer_workoutlog t
                    SET customer_id = c.id
                    FROM customers_customer c
                    WHERE c.user_id = t.customer_id;

                UPDATE trainer_prrecord t
                    SET customer_id = c.id
                    FROM customers_customer c
                    WHERE c.user_id = t.customer_id;
            """,
            reverse_sql=migrations.RunSQL.noop,
        ),

        # AlterField will add the new FK constraint pointing to customers.Customer
        migrations.AlterField(
            model_name='customerworkoutplan',
            name='customer',
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE,
                related_name='customer_workout_plans',
                to='customers.customer',
            ),
        ),
        migrations.AlterField(
            model_name='workoutsession',
            name='customer',
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE,
                related_name='workout_sessions',
                to='customers.customer',
            ),
        ),
        migrations.AlterField(
            model_name='workoutlog',
            name='customer',
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE,
                related_name='workout_logs',
                to='customers.customer',
            ),
        ),
        migrations.AlterField(
            model_name='prrecord',
            name='customer',
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.CASCADE,
                related_name='pr_records',
                to='customers.customer',
            ),
        ),
    ]
