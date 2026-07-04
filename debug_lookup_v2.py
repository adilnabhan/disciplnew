
import os
import django
import traceback

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from apps.trainer.models import Trainer
from django.db import connection

try:
    with connection.cursor() as cursor:
        print("Checking TrainerSubscriptionPlan ID type...")
        cursor.execute("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'trainer_trainersubscriptionplan' AND column_name = 'id'")
        print(f"Plan ID type: {cursor.fetchone()}")
        
        print("\nChecking TrainerSubscription plan_id type...")
        cursor.execute("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'trainer_trainersubscription' AND column_name = 'plan_id'")
        print(f"FK plan_id type: {cursor.fetchone()}")

    from apps.trainer.models import Trainer
    t = Trainer.objects.get(id=4)
    print(f"Trainer 4 found: {t}")
    
    print("\nAttempting to serialize Trainer 4...")
    from apps.trainer.serializers import TrainerDetailSerializer
    data = TrainerDetailSerializer(t).data
    print("Serialization successful!")
    print(f"Data: {data}")

except Exception as e:
    print(f"\nERROR: {str(e)}")
    traceback.print_exc()

except Exception as e:
    print(f"\nERROR: {str(e)}")
    traceback.print_exc()
    # Check if there are any pending migrations or schema issues
    with connection.cursor() as cursor:
        cursor.execute("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'trainer_trainer'")
        columns = cursor.fetchall()
        print("\nTable columns for trainer_trainer:")
        for col in columns:
            print(col)
