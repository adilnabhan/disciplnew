import os
import openpyxl
from django.core.management.base import BaseCommand
from django.utils.text import slugify
from django.contrib.gis.geos import Point

from apps.fitnesscenter.models import (
    Organization,
    Category,
    Amenity,
    organizationAmenity,
    Location,
    WorkingDay,
    SocialMedia,
    OrganizationPhoto,
)
from apps.user.models import User
from apps.mentors.models import MentorProfile
from apps.fitnesscenter.image_utils import resolve_image_file

class Command(BaseCommand):
    help = 'Import gyms from Kerala_Gyms_OSM_Filled.xlsx into the database'

    def add_arguments(self, parser):
        parser.add_argument(
            '--file',
            type=str,
            default='../Kerala_Gyms_OSM_Filled.xlsx',
            help='Path to the Excel file'
        )
        parser.add_argument(
            '--image-dir',
            type=str,
            default='',
            help='Directory containing local gym images/logos'
        )

    def handle(self, *args, **options):
        file_path = options['file']
        image_dir = options.get('image_dir', '')
        if not os.path.exists(file_path):
            self.stdout.write(self.style.ERROR(f"File not found at: {file_path}"))
            return

        self.stdout.write(self.style.SUCCESS(f"Loading workbook: {file_path}"))
        wb = openpyxl.load_workbook(file_path, data_only=True)
        sheet = wb.active

        # Extract headers and map column names to index
        headers = [str(cell.value).strip().lower() for cell in sheet[1]]
        col_map = {name: idx for idx, name in enumerate(headers)}

        def get_val(row, field_name):
            idx = col_map.get(field_name)
            if idx is None or idx >= len(row):
                return None
            val = row[idx]
            if val is None or str(val).strip() == '':
                return None
            return val

        # Iterate rows
        success_count = 0
        update_count = 0
        error_count = 0

        # Helper mapping for day codes
        DAY_MAP = {
            'monday': 'mon',
            'tuesday': 'tue',
            'wednesday': 'wed',
            'thursday': 'thu',
            'friday': 'fri',
            'saturday': 'sat',
            'sunday': 'sun'
        }

        # Load rows (starting from row 2)
        rows = list(sheet.iter_rows(min_row=2, values_only=True))
        total_rows = len([r for r in rows if r[0] is not None])
        self.stdout.write(f"Found {total_rows} gym records to import.")

        for row_idx, row in enumerate(rows, start=2):
            name = get_val(row, 'name')
            if not name:
                continue

            try:
                # 1. Extract location fields early to use for matching
                city = get_val(row, 'city') or 'Kerala'

                # Try to find existing organization by name AND city
                org = Organization.objects.filter(name=name, location__city=city).first()
                created = False

                slug = None
                if not org:
                    slug = slugify(name)[:40]
                    # Ensure unique slug in case of duplicate names
                    base_slug = slug
                    counter = 1
                    while Organization.objects.filter(slug=slug).exists():
                        slug = f"{base_slug}-{counter}"
                        counter += 1

                email = get_val(row, 'email')
                if not email:
                    email = f"info@{slugify(name)[:30]}.com"

                phone = get_val(row, 'phone_number')
                if not phone:
                    phone = get_val(row, 'secondary_phone')
                if not phone:
                    phone = "+919900012345"
                # Ensure it fits max_length=15
                phone = str(phone).replace(" ", "")[:15]

                description = get_val(row, 'description')
                if not description:
                    description = f"Welcome to {name}. Experience top-tier training environment, premium gear, and expert coaching."

                if not org:
                    org = Organization.objects.create(
                        name=name,
                        slug=slug,
                        email=email,
                        phone_number=phone,
                        description=description,
                        is_public=True,
                        active=True,
                        is_slot_available=True,
                    )
                    created = True
                    success_count += 1
                else:
                    # Update fields if already exists
                    org.email = email
                    org.phone_number = phone
                    org.description = description
                    org.is_public = True
                    org.active = True
                    org.save()
                    update_count += 1

                # Import logo if present in the row
                logo_val = get_val(row, 'logo') or get_val(row, 'logo_image') or get_val(row, 'image')
                if logo_val:
                    filename, file_content = resolve_image_file(logo_val, search_dirs=[image_dir])
                    if file_content:
                        org.logo.save(filename, file_content, save=True)

                # Import gallery photos if present in the row
                photos_val = get_val(row, 'photos') or get_val(row, 'images')
                if photos_val:
                    photo_list = [p.strip() for p in str(photos_val).split(';') if p.strip()]
                    if len(photo_list) == 1 and ',' in photo_list[0]:
                        photo_list = [p.strip() for p in photo_list[0].split(',') if p.strip()]

                    for i, photo_item in enumerate(photo_list):
                        p_filename, p_file_content = resolve_image_file(photo_item, search_dirs=[image_dir])
                        if p_file_content:
                            if not org.photos.filter(image__contains=p_filename).exists():
                                OrganizationPhoto.objects.create(
                                    organization=org,
                                    image=p_file_content,
                                    is_primary=(i == 0 and not org.photos.exists())
                                )

                # 2. Map Categories
                categories_str = get_val(row, 'categories')
                if categories_str:
                    cat_list = [c.strip() for c in str(categories_str).split(';') if c.strip()]
                    for cat_name in cat_list:
                        # Clean up / normalise category names
                        if cat_name.lower() in ['fitness centre', 'gym / fitness', 'fitness', 'health club', 'exercise', 'bodybuilding']:
                            cat_name = 'Gym'
                        elif cat_name.lower() in ['crossfit', 'crossfit; fitness centre']:
                            cat_name = 'CrossFit'
                        elif cat_name.lower() == 'yoga':
                            cat_name = 'Yoga'

                        # Ensure Category exists in DB
                        cat_obj, _ = Category.objects.get_or_create(
                            name=cat_name,
                            defaults={'is_active': True}
                        )
                        org.category.add(cat_obj)
                else:
                    # Default category
                    gym_cat, _ = Category.objects.get_or_create(name='Gym', defaults={'is_active': True})
                    org.category.add(gym_cat)

                # 3. Create or Update Location
                city = get_val(row, 'city') or 'Kerala'
                state = get_val(row, 'state') or 'Kerala'
                building_name = get_val(row, 'building_name') or name
                street = get_val(row, 'street') or 'Kerala'
                pin_code = get_val(row, 'pin_code') or '682001'
                
                lat = get_val(row, 'latitude')
                lon = get_val(row, 'longitude')

                geom_point = None
                if lat is not None and lon is not None:
                    try:
                        geom_point = Point(float(lon), float(lat), srid=4326)
                    except Exception:
                        pass

                Location.objects.update_or_create(
                    organization=org,
                    defaults={
                        'building_name': building_name[:100],
                        'street': street[:200],
                        'city': city[:100],
                        'state': state[:100],
                        'pin_code': str(pin_code)[:10],
                        'latitude': lat,
                        'longitude': lon,
                        'location': geom_point
                    }
                )

                # 4. Map Working Days (Schedules)
                for day_name, day_code in DAY_MAP.items():
                    # Check if day is open
                    day_open_val = get_val(row, f"{day_name}_open")
                    
                    # By default: Mon-Sat is open, Sun is closed unless specified
                    is_open = True
                    if day_name == 'sunday':
                        is_open = False
                    
                    if day_open_val is not None:
                        is_open = str(day_open_val).strip().lower() in ['yes', 'true', '1', 'open']

                    morning_open = get_val(row, f"{day_name}_morning_open") or "06:00:00"
                    morning_close = get_val(row, f"{day_name}_morning_close") or "11:00:00"
                    evening_open = get_val(row, f"{day_name}_evening_open") or "16:00:00"
                    evening_close = get_val(row, f"{day_name}_evening_close") or "21:00:00"

                    WorkingDay.objects.update_or_create(
                        organization=org,
                        day=day_code,
                        defaults={
                            'is_open': is_open,
                            'morning_opening_time': morning_open,
                            'morning_closing_time': morning_close,
                            'evening_opening_time': evening_open,
                            'evening_closing_time': evening_close,
                            'ladies_opening_time': get_val(row, f"{day_name}_ladies_open") or None,
                            'ladies_closing_time': get_val(row, f"{day_name}_ladies_close") or None,
                        }
                    )

                # 5. Map Amenities
                amenities_str = get_val(row, 'amenities')
                if amenities_str:
                    amenity_list = [a.strip() for a in str(amenities_str).split(';') if a.strip()]
                    for amen_name in amenity_list:
                        # Clean up tag-like values e.g. "Air Conditioning: yes" -> "Air Conditioning"
                        if ':' in amen_name:
                            parts = amen_name.split(':')
                            if parts[1].strip().lower() in ['yes', 'true', 'wlan']:
                                amen_name = parts[0].strip()
                            else:
                                continue # Skip values like "Access: private", "Fee: no"

                        amen_obj, _ = Amenity.objects.get_or_create(name=amen_name)
                        organizationAmenity.objects.get_or_create(
                            organization=org,
                            amenity=amen_obj
                        )

                # 6. Map Social Media Linkages
                social_platforms = ['instagram', 'facebook', 'youtube', 'website']
                for platform in social_platforms:
                    url = get_val(row, platform)
                    if url:
                        SocialMedia.objects.update_or_create(
                            organization=org,
                            platform=platform,
                            defaults={'url': str(url)}
                        )

                # 7. Auto-create Mentor User for testing ERP
                mentor_username = f"mentor_{org.slug}"[:30]
                user, user_created = User.objects.get_or_create(
                    username=mentor_username,
                    defaults={
                        'email': org.email or f"mentor@{org.slug}.com",
                        'first_name': org.name[:30],
                        'is_staff': True,
                        'is_superuser': False,
                        'user_role': User.MENTOR,
                    }
                )
                if user_created:
                    user.set_password("Password@123")
                    user.save()

                mentor_profile, _ = MentorProfile.objects.get_or_create(user=user)
                if not org.mentor or org.mentor != mentor_profile:
                    org.mentor = mentor_profile
                    org.save(update_fields=['mentor'])

                if (row_idx - 1) % 50 == 0 or row_idx == len(rows) + 1:
                    self.stdout.write(f"Processed {row_idx - 1} records...")

            except Exception as e:
                error_count += 1
                self.stdout.write(self.style.ERROR(f"Error processing row {row_idx} ({name}): {str(e)}"))

        self.stdout.write(self.style.SUCCESS(
            f"Import summary:\n"
            f"  Created   : {success_count}\n"
            f"  Updated   : {update_count}\n"
            f"  Errors    : {error_count}"
        ))
