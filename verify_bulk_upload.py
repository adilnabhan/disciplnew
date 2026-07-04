import os
import django

# Initialize Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

import openpyxl
from django.db import transaction
from django.core.management import call_command
from apps.fitnesscenter.admin import OrganizationResource
from apps.fitnesscenter.models import Organization

def test_excel_schema():
    file_path = '../Kerala_Gyms_OSM_Filled.xlsx'
    if not os.path.exists(file_path):
        # Check current directory if parent doesn't have it
        file_path = 'Kerala_Gyms_OSM_Filled.xlsx'
    
    if not os.path.exists(file_path):
        print(f"Error: {file_path} not found.")
        return False
        
    print(f"Loading Excel file: {file_path}")
    wb = openpyxl.load_workbook(file_path, data_only=True)
    sheet = wb.active
    
    headers = [str(cell.value).strip().lower() for cell in sheet[1] if cell.value is not None]
    print("\n--- Excel Headers Found ---")
    print(headers)
    
    # 1. Validate mandatory fields
    mandatory_fields = ['name', 'email', 'phone_number']
    missing = [f for f in mandatory_fields if f not in headers]
    if missing:
        print(f"[FAIL] Missing mandatory headers for standard import: {missing}")
    else:
        print("[PASS] All mandatory headers are present.")

    # 2. Perform a dry-run import of the first 5 rows within a transaction
    print("\n--- Dry-running import of first 5 records ---")
    rows = list(sheet.iter_rows(min_row=2, values_only=True))
    valid_rows = [r for r in rows if r[0] is not None][:5]
    print(f"Dry-running with {len(valid_rows)} records...")

    try:
        with transaction.atomic():
            # Let's map column name to index
            col_map = {name: idx for idx, name in enumerate(headers)}
            
            for idx, row in enumerate(valid_rows, start=1):
                name = row[col_map.get('name')]
                email = row[col_map.get('email')] or f"info@{name.lower().replace(' ', '')}.com"
                phone = row[col_map.get('phone_number')] or "+919900012345"
                
                print(f"Row {idx}: Name={name}, Email={email}, Phone={phone}")
                
                # Try creating a test org
                org, created = Organization.objects.get_or_create(
                    name=name,
                    defaults={
                        'email': email,
                        'phone_number': str(phone)[:15],
                        'description': 'Test description',
                        'active': True
                    }
                )
                print(f"  -> Organization {'Created' if created else 'Already Exists'} (ID: {org.id})")
                
            # Rollback transaction so we don't commit any test data
            print("\nRolling back transaction to keep DB clean...")
            transaction.set_rollback(True)
        print("[PASS] Database transaction dry-run succeeded without IntegrityErrors.")
        return True
    except Exception as e:
        print(f"[FAIL] Exception occurred during dry-run: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    test_excel_schema()
