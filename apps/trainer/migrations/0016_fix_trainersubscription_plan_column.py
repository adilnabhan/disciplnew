from django.db import migrations


class Migration(migrations.Migration):

    atomic = False

    dependencies = [
        ('trainer', '0015_workout_customer_fk_to_customer'),
    ]

    operations = [
        migrations.RunSQL(
            sql="""
                -- Step 1: Drop ALL FK constraints on plan_id (whatever name they have)
                DO $$
                DECLARE
                    r RECORD;
                BEGIN
                    FOR r IN (
                        SELECT conname
                        FROM pg_constraint
                        WHERE conrelid = 'trainer_trainersubscription'::regclass
                          AND contype = 'f'
                          AND conkey @> ARRAY[
                              (SELECT attnum FROM pg_attribute
                               WHERE attrelid = 'trainer_trainersubscription'::regclass
                               AND attname = 'plan_id')
                          ]::smallint[]
                    ) LOOP
                        EXECUTE 'ALTER TABLE trainer_trainersubscription DROP CONSTRAINT IF EXISTS ' || quote_ident(r.conname);
                    END LOOP;
                END $$;

                -- Step 2: Truncate since old UUID values can't map to bigint
                TRUNCATE TABLE trainer_trainersubscription;

                -- Step 3: Change plan_id from uuid to bigint
                ALTER TABLE trainer_trainersubscription
                    ALTER COLUMN plan_id TYPE bigint USING NULL;

                -- Step 4: Add correct FK to trainer_trainersubscriptionplan
                ALTER TABLE trainer_trainersubscription
                    ADD CONSTRAINT trainer_trainersubscription_plan_id_fkey
                        FOREIGN KEY (plan_id) REFERENCES trainer_trainersubscriptionplan(id) ON DELETE RESTRICT;
            """,
            reverse_sql=migrations.RunSQL.noop,
        ),
    ]
