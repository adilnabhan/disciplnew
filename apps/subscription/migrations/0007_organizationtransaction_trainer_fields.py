from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('subscription', '0006_add_settled_status_to_partner_transfer'),
        ('trainer', '0012_trainersubscription'),
    ]

    operations = [
        # Update Django state only - columns already exist in DB from previous deploy
        migrations.SeparateDatabaseAndState(
            state_operations=[
                migrations.AddField(
                    model_name='organizationtransaction',
                    name='trainer',
                    field=models.ForeignKey(
                        blank=True, null=True,
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name='subscription_orders',
                        to='trainer.trainer',
                    ),
                ),
                migrations.AddField(
                    model_name='organizationtransaction',
                    name='trainer_plan',
                    field=models.ForeignKey(
                        blank=True, null=True,
                        on_delete=django.db.models.deletion.PROTECT,
                        to='trainer.trainersubscriptionplan',
                    ),
                ),
            ],
            database_operations=[],
        ),
        # Add columns if they don't already exist
        migrations.RunSQL(
            sql="""
                ALTER TABLE subscription_organizationtransaction
                    ADD COLUMN IF NOT EXISTS trainer_id bigint REFERENCES trainer_trainer(id) ON DELETE CASCADE,
                    ADD COLUMN IF NOT EXISTS trainer_plan_id bigint REFERENCES trainer_trainersubscriptionplan(id) ON DELETE RESTRICT;
            """,
            reverse_sql="""
                ALTER TABLE subscription_organizationtransaction
                    DROP COLUMN IF EXISTS trainer_id,
                    DROP COLUMN IF EXISTS trainer_plan_id;
            """,
        ),
    ]
