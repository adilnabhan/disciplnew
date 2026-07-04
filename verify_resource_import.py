import os
import django

# Initialize Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'discipl.settings')
django.setup()

import openpyxl
from tablib import Dataset
from django.db import transaction
from apps.fitnesscenter.admin import OrganizationResource
from apps.fitnesscenter.models import WorkingDay, Location, Organization

def test_resource_import():
    file_path = '../Kerala_Gyms_OSM_Filled.xlsx'
    if not os.path.exists(file_path):
        file_path = 'Kerala_Gyms_OSM_Filled.xlsx'
        
    if not os.path.exists(file_path):
        print(f"Error: {file_path} not found.")
        return False
        
    print(f"Loading Excel file: {file_path}")
    wb = openpyxl.load_workbook(file_path, data_only=True)
    sheet = wb.active
    
    # Read headers
    headers = [str(cell.value).strip() for cell in sheet[1] if cell.value is not None]
    
    # Read first row of data
    first_data_row = []
    for cell in list(sheet.iter_rows(min_row=2, max_row=2, values_only=True))[0]:
        first_data_row.append(cell)
        
    # Create tablib Dataset
    dataset = Dataset(headers=headers)
    dataset.append(first_data_row)
    
    # Initialize resource
    resource = OrganizationResource()
    
    try:
        with transaction.atomic():
            # Run dry-run import first
            result = resource.import_data(dataset, dry_run=True)
            print("\nDry Run Results:")
            print(f"Has errors: {result.has_errors()}")
            for error in result.base_errors:
                print(f"Base Error: {error}")
            for row_idx, row_errors in result.row_errors():
                print(f"Row {row_idx} Errors: {row_errors}")
                
            # Run actual import in transaction
            result_real = resource.import_data(dataset, dry_run=False)
            print(f"\nReal Import - Has errors: {result_real.has_errors()}")
            if result_real.has_errors():
                for error in result_real.base_errors:
                    print(f"Real Base Error: {error}")
                for row_idx, row_errors in result_real.row_errors():
                    print(f"Real Row {row_idx} Errors: {row_errors}")
            
            # Retrieve the created organization
            org_name = first_data_row[headers.index('name')]
            org = Organization.objects.filter(name=org_name).first()
            if org:
                print(f"Created Org: {org.name} (ID: {org.id})")
                loc = Location.objects.filter(organization=org).first()
                if loc:
                    print(f"Created Location: City={loc.city}, Street={loc.street}")
                else:
                    print("No Location created!")
                    
                working_days = WorkingDay.objects.filter(organization=org)
                print(f"Created Working Days: {working_days.count()}")
                for wd in working_days:
                    print(f"  {wd.day}: Open={wd.is_open}, Morning={wd.morning_opening_time}-{wd.morning_closing_time}")
            else:
                print("Failed to find created Organization!")
                
            # Rollback
            transaction.set_rollback(True)
            print("\nTransaction rolled back successfully.")
            return True
    except Exception as e:
        print(f"Exception during import: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    test_resource_import()
