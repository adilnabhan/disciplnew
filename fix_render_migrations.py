import os
import django

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

from django.db import connection
from django.db.migrations.recorder import MigrationRecorder

def fix_migration():
    print("Initializing migration check...")
    recorder = MigrationRecorder(connection)
    applied = recorder.applied_migrations()
    
    app_label = 'trainer'
    migration_name = '0010_gym_trainer_workout_overrides'
    
    if (app_label, migration_name) in applied:
        print(f"Migration {app_label}.{migration_name} is already marked as applied.")
    else:
        print(f"Migration {app_label}.{migration_name} is NOT marked as applied.")
        print("Recording it as applied to resolve the InconsistentMigrationHistory error...")
        recorder.record_applied(app_label, migration_name)
        print("Successfully recorded! You can now run 'python manage.py migrate'.")

if __name__ == '__main__':
    fix_migration()
