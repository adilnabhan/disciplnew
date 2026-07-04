
import os
import django
import traceback

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from apps.trainer.models import Trainer

try:
    print("Testing Trainer ID lookup...")
    t = Trainer.objects.filter(id=4).first()
    print(f"Found by ID: {t}")
    
    print("\nTesting User ID lookup...")
    # Use exact field name from model
    t2 = Trainer.objects.filter(user_id=4).first()
    print(f"Found by User ID: {t2}")
    
except Exception as e:
    print(f"\nERROR: {str(e)}")
    traceback.print_exc()
