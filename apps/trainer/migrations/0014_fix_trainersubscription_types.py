
from django.db import migrations, models
import django.db.models.deletion

class Migration(migrations.Migration):

    dependencies = [
        ('trainer', '0013_trainer_profile_fields_optional'),
    ]

    operations = [
        # This migration is no longer needed - plan_id is already properly defined
        # in TrainerSubscription model via ForeignKey to TrainerSubscriptionPlan
        # Kept as empty migration to maintain migration history
    ]
