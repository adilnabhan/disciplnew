from django import forms
from django.contrib import admin
from import_export import resources, fields
from import_export.admin import ImportExportModelAdmin
from import_export.widgets import ManyToManyWidget

from apps.fitnesscenter.models import (
    BankAccountDetails,
    Category,
    Amenity,
    Organization,
    Location,
    WorkingDay,
    organizationAmenity,
    OrganizationPhoto,
    SocialMedia,
    MembershipPlan,
    EmiPlan,
    OrganizationTimeSlot,
)
from apps.user.models import User
from apps.mentors.models import MentorProfile
from apps.fitnesscenter.image_utils import resolve_image_file


class OrganizationResource(resources.ModelResource):
    """
    Bulk CSV/XLSX import for Organizations (unregistered gyms).

    CSV columns:
        name            (required)
        email           (required)
        phone_number    (required)
        description
        mentor_username     username for mentor login (auto-creates user)
        mentor_password     password for mentor login
        categories      comma-separated category names e.g. "Gym,CrossFit"
        amenities       comma-separated amenity names e.g. "Parking,Locker Room"
        city
        state
        building_name   (min 10 chars)
        street          (min 10 chars)
        pin_code
        latitude
        longitude
        instagram       URL
        facebook        URL
        youtube         URL
        twitter         URL
        whatsapp        phone number
        website         URL
        mon_open        True/False
        mon_morning_open    HH:MM
        mon_morning_close   HH:MM
        mon_evening_open    HH:MM
        mon_evening_close   HH:MM
        (repeat for tue, wed, thu, fri, sat, sun)
    """
    categories = fields.Field(
        column_name='categories',
        attribute='category',
        widget=ManyToManyWidget(Category, field='name', separator=',')
    )

    class Meta:
        model = Organization
        import_id_fields = ['name', 'email']
        fields = [
            'id', 'name', 'email', 'phone_number', 'description',
            'categories', 'registration_status',
        ]
        skip_unchanged = True
        report_skipped = True

    def before_import_row(self, row, row_number=None, **kwargs):
        row['registration_status'] = 'unregistered'
        for key, value in list(row.items()):
            if value is None:
                row[key] = ''
            elif isinstance(value, str):
                row[key] = value.strip()

        # Fallbacks for missing/null fields
        name = row.get('name')
        if name:
            name = name.strip()
            
            # 1. Email fallback
            if not row.get('email'):
                from django.utils.text import slugify
                row['email'] = f"info@{slugify(name)[:30]}.com"
                
            # 2. Phone fallback
            phone = row.get('phone_number')
            if not phone:
                phone = row.get('secondary_phone')
            if not phone:
                phone = "+919900012345"
            row['phone_number'] = str(phone).replace(" ", "")[:15]
            
            # 3. Description fallback
            if not row.get('description'):
                row['description'] = f"Welcome to {name}. Experience top-tier training environment, premium gear, and expert coaching."

        # Map full day names to short names for schedules
        day_map = {
            'monday': 'mon', 'tuesday': 'tue', 'wednesday': 'wed',
            'thursday': 'thu', 'friday': 'fri', 'saturday': 'sat', 'sunday': 'sun'
        }
        suffixes = ['_open', '_morning_open', '_morning_close', '_evening_open', '_evening_close']
        for long_day, short_day in day_map.items():
            for suffix in suffixes:
                long_key = f"{long_day}{suffix}"
                short_key = f"{short_day}{suffix}"
                if long_key in row and row[long_key] is not None:
                    row[short_key] = row[long_key]

    def after_save_instance(self, instance, row, **kwargs):
        dry_run = kwargs.get('dry_run', False)
        if dry_run:
            return

        # ── Mentor User (username/password login) ────────────────────────
        mentor_username = row.get('mentor_username', '').strip()
        mentor_password = row.get('mentor_password', '').strip()
        if mentor_username and mentor_password:
            user, created = User.objects.get_or_create(
                username=mentor_username,
                defaults={
                    'email': instance.email or '',
                    'first_name': instance.name,
                    'is_staff': True,
                    'is_superuser': False,
                    'user_role': User.MENTOR,
                }
            )
            if created:
                user.set_password(mentor_password)
                user.save()
            mentor_profile, _ = MentorProfile.objects.get_or_create(user=user)
            instance.mentor = mentor_profile
            instance.save(update_fields=['mentor'])

        # ── Location ─────────────────────────────────────────────────────
        city = row.get('city', '').strip()
        if city:
            building_name = row.get('building_name', '').strip() or 'N/A - Please update'
            street = row.get('street', '').strip() or 'N/A - Please update'
            # Pad to meet 10-char minimum if needed
            if len(building_name) < 10:
                building_name = building_name.ljust(10)
            if len(street) < 10:
                street = street.ljust(10)
            Location.objects.update_or_create(
                organization=instance,
                defaults={
                    'building_name': building_name,
                    'street': street,
                    'city': city,
                    'state': row.get('state', '').strip(),
                    'pin_code': row.get('pin_code', '').strip(),
                    'latitude': row.get('latitude') or None,
                    'longitude': row.get('longitude') or None,
                }
            )

        # ── Social Media ──────────────────────────────────────────────────
        social_platforms = ['instagram', 'facebook', 'youtube', 'twitter', 'whatsapp', 'website']
        for platform in social_platforms:
            url = row.get(platform, '').strip()
            if url:
                SocialMedia.objects.update_or_create(
                    organization=instance,
                    platform=platform,
                    defaults={'url': url}
                )

        # ── Amenities ─────────────────────────────────────────────────────
        amenities_str = row.get('amenities', '').strip()
        if amenities_str:
            for amenity_name in amenities_str.split(','):
                amenity_name = amenity_name.strip()
                if amenity_name:
                    amenity = Amenity.objects.filter(name__iexact=amenity_name).first()
                    if amenity:
                        organizationAmenity.objects.get_or_create(
                            organization=instance,
                            amenity=amenity
                        )

        # ── Working Days / Schedules ──────────────────────────────────────
        days = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
        day_map = {
            'mon': 'mon', 'tue': 'tue', 'wed': 'wed',
            'thu': 'thu', 'fri': 'fri', 'sat': 'sat', 'sun': 'sun'
        }
        for day in days:
            is_open_val = row.get(f'{day}_open', '').strip().lower()
            if is_open_val in ('true', 'false', '1', '0', 'yes', 'no'):
                is_open = is_open_val in ('true', '1', 'yes')
                WorkingDay.objects.update_or_create(
                    organization=instance,
                    day=day_map[day],
                    defaults={
                        'is_open': is_open,
                        'morning_opening_time': row.get(f'{day}_morning_open') or None,
                        'morning_closing_time': row.get(f'{day}_morning_close') or None,
                        'evening_opening_time': row.get(f'{day}_evening_open') or None,
                        'evening_closing_time': row.get(f'{day}_evening_close') or None,
                        'ladies_opening_time': row.get(f'{day}_ladies_open') or None,
                        'ladies_closing_time': row.get(f'{day}_ladies_close') or None,
                    }
                )

        # ── Logo and Photos ───────────────────────────────────────────────
        def get_row_val(row_dict, *keys):
            for k in keys:
                if k in row_dict:
                    return row_dict[k]
                if k.lower() in row_dict:
                    return row_dict[k.lower()]
                for row_key, val in row_dict.items():
                    if str(row_key).strip().lower() == k.lower():
                        return val
            return None

        logo_val = get_row_val(row, 'logo', 'logo_image', 'image')
        if logo_val:
            filename, file_content = resolve_image_file(logo_val)
            if file_content:
                instance.logo.save(filename, file_content, save=True)

        photos_val = get_row_val(row, 'photos', 'images')
        if photos_val:
            photo_list = [p.strip() for p in str(photos_val).split(';') if p.strip()]
            if len(photo_list) == 1 and ',' in photo_list[0]:
                photo_list = [p.strip() for p in photo_list[0].split(',') if p.strip()]

            for i, photo_item in enumerate(photo_list):
                p_filename, p_file_content = resolve_image_file(photo_item)
                if p_file_content:
                    if not instance.photos.filter(image__contains=p_filename).exists():
                        OrganizationPhoto.objects.create(
                            organization=instance,
                            image=p_file_content,
                            is_primary=(i == 0 and not instance.photos.exists())
                        )


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ['name', 'is_active', 'display_order']
    list_editable = ['is_active', 'display_order']
    ordering = ['display_order']
    search_fields = ['name']

    def has_module_permission(self, request):
        """Only superusers can see Category in the admin sidebar."""
        if request.user.is_superuser:
            return True
        return False


@admin.register(Amenity)
class AmenityAdmin(admin.ModelAdmin):
    list_display = ['name', 'display_order']
    list_editable = ['display_order']
    search_fields = ['name']
    ordering = ['display_order']

    def has_module_permission(self, request):
        """Only superusers can see Amenity in the admin sidebar."""
        if request.user.is_superuser:
            return True
        return False


# ──────────────────────────────────────────────────────────
#  Restricted-safe inline for Location (editable fields only)
# ──────────────────────────────────────────────────────────
class LocationInline(admin.StackedInline):
    model = Location
    extra = 0

    def get_fields(self, request, obj=None):
        """Restricted staff see only address fields; superusers see everything."""
        if request.user.is_superuser:
            return super().get_fields(request, obj)
        return [
            'building_name', 'street', 'city', 'state', 'pin_code',
            'latitude', 'longitude',
        ]


class WorkingDayInline(admin.TabularInline):
    model = WorkingDay
    extra = 0


class OrganizationPhotoInline(admin.TabularInline):
    model = OrganizationPhoto
    extra = 0


class SocialMediaInline(admin.TabularInline):
    model = SocialMedia
    extra = 0


class organizationAmenityInline(admin.TabularInline):
    model = organizationAmenity
    extra = 0

class OrganizationTimeSlotInline(admin.TabularInline):
    model = OrganizationTimeSlot
    extra = 1
    fields = ('name', 'start_time', 'end_time', 'is_active', 'start_date', 'end_date')


class MembershipPlanInline(admin.TabularInline):
    model = MembershipPlan
    extra = 1
    fields = ('name', 'package_type', 'actual_price', 'offer_price', 'duration_days', 'is_active', 'is_emi_available')


# ──────────────────────────────────────────────────────────
#  Organization Admin — full for superuser, restricted for staff
# ──────────────────────────────────────────────────────────

# Fields that a restricted staff user is allowed to edit
RESTRICTED_EDITABLE_FIELDS = [
    'name', 'description', 'email', 'phone_number', 'logo',
    'birthday_wish_message', 'anniversary_wish_message',
]

# Fields shown as read-only to restricted staff (visible but not editable)
RESTRICTED_READONLY_FIELDS = [
    'slug', 'active', 'is_subscribed', 'is_on_free_trial',
    'is_public', 'profile_completeness', 'review_count',
    'average_rating', 'is_slot_available', 'created_at', 'updated_at',
]


@admin.register(Organization)
class OrganizationAdmin(ImportExportModelAdmin):
    resource_classes = [OrganizationResource]
    list_display = [
        'name', 'registration_status', 'mentor', 'mentor_username_display',
        'active', 'is_subscribed', 'is_on_free_trial', 'created_at'
    ]
    list_filter = ['registration_status', 'active', 'is_subscribed', 'is_on_free_trial']
    search_fields = ['name', 'email', 'phone_number']
    prepopulated_fields = {'slug': ('name',)}
    inlines = [
        LocationInline,
        WorkingDayInline,
        OrganizationTimeSlotInline,
        organizationAmenityInline,
        OrganizationPhotoInline,
        SocialMediaInline,
        MembershipPlanInline,
    ]
    filter_horizontal = ('category',)
    readonly_fields = ['created_at', 'updated_at', 'mentor_username_display']

    def mentor_username_display(self, obj):
        """Show the mentor's login username in the list."""
        if obj.mentor and obj.mentor.user:
            return obj.mentor.user.username
        return '—'
    mentor_username_display.short_description = 'Mentor Login'

    # Virtual fields that exist on the form but NOT on the model
    VIRTUAL_FIELDS = {'mentor_login_username', 'mentor_login_password'}

    def get_form(self, request, obj=None, **kwargs):
        """Use custom form with virtual mentor fields for superusers.

        Django's default get_form() flattens fieldsets into a 'fields' list
        and passes it to modelform_factory, which validates every field
        against the model. Our virtual mentor fields only exist on the
        ModelForm subclass, so we must strip them before calling super().
        """
        # Let Django build the fields list from fieldsets normally,
        # but override the 'fields' kwarg to exclude virtual fields.
        if 'fields' not in kwargs:
            from django.contrib.admin.options import flatten_fieldsets
            fieldsets = self.get_fieldsets(request, obj)
            fields = list(flatten_fieldsets(fieldsets))
            # Remove virtual fields so modelform_factory won't choke
            kwargs['fields'] = [f for f in fields if f not in self.VIRTUAL_FIELDS]
        kwargs.setdefault('form', self.form)
        return super().get_form(request, obj, **kwargs)

    # ── Dynamic fieldsets based on user role ──

    def get_fieldsets(self, request, obj=None):
        """
        Superusers: see all fields + mentor credentials section.
        Restricted staff: see only safe-to-edit fields + read-only status fields.
        """
        if request.user.is_superuser:
            default_fieldsets = super().get_fieldsets(request, obj)
            # Add mentor credentials section for superusers
            default_fieldsets = list(default_fieldsets) + [
                ('Mentor Login Credentials', {
                    'fields': ['mentor_login_username', 'mentor_login_password'],
                    'classes': ['collapse'],
                    'description': 'Set username & password for mentor app login. '
                                   'Login API: POST /api/v1/user/login/ with {"username": "...", "password": "..."}',
                }),
            ]
            return default_fieldsets

        return [
            ('Basic Information', {
                'fields': ['name', 'description', 'email', 'phone_number', 'logo'],
            }),
            ('Messages', {
                'fields': ['birthday_wish_message', 'anniversary_wish_message'],
                'classes': ['collapse'],
            }),
            ('Status (read-only)', {
                'fields': RESTRICTED_READONLY_FIELDS,
                'classes': ['collapse'],
            }),
        ]

    def get_readonly_fields(self, request, obj=None):
        """Restricted staff can only view status fields — not edit them."""
        if request.user.is_superuser:
            return self.readonly_fields or []
        return RESTRICTED_READONLY_FIELDS

    # ── Mentor login credentials (virtual form fields) ──
    class OrganizationAdminForm(forms.ModelForm):
        mentor_login_username = forms.CharField(
            required=False,
            label='Mentor Username',
            help_text='Username for mentor app login',
        )
        mentor_login_password = forms.CharField(
            required=False,
            widget=forms.PasswordInput(render_value=False),
            label='Set/Change Password',
            help_text='Leave blank to keep current password',
        )

        class Meta:
            model = Organization
            fields = '__all__'

    form = OrganizationAdminForm

    def save_model(self, request, obj, form, change):
        """
        Handle mentor username/password creation when saving from admin.
        """
        super().save_model(request, obj, form, change)

        if not request.user.is_superuser:
            return

        username = form.cleaned_data.get('mentor_login_username', '').strip()
        password = form.cleaned_data.get('mentor_login_password', '').strip()

        if not username:
            return

        # Get or create the mentor user
        if obj.mentor and obj.mentor.user:
            # Update existing mentor user
            user = obj.mentor.user
            if user.username != username:
                user.username = username
                user.save(update_fields=['username'])
            if password:
                user.set_password(password)
                user.save(update_fields=['password'])
        else:
            # Create new user + mentor profile
            user, created = User.objects.get_or_create(
                username=username,
                defaults={
                    'email': obj.email or '',
                    'first_name': obj.name,
                    'is_staff': True,
                    'is_superuser': False,
                    'user_role': User.MENTOR,
                }
            )
            if created and password:
                user.set_password(password)
                user.save()
            elif created:
                user.set_password('Discipl@123')  # default password
                user.save()

            mentor_profile, _ = MentorProfile.objects.get_or_create(user=user)
            obj.mentor = mentor_profile
            obj.save(update_fields=['mentor'])

    def get_prepopulated_fields(self, request, obj=None):
        """Disable slug auto-fill for restricted users (slug is read-only for them)."""
        if request.user.is_superuser:
            return self.prepopulated_fields
        return {}

    def get_inlines(self, request, obj=None):
        """
        Restricted staff: Location, WorkingDay, Photos, SocialMedia, Amenities, TimeSlots, Plans.
        Superusers: all inlines.
        """
        if request.user.is_superuser:
            return self.inlines
        return [
            LocationInline,
            WorkingDayInline,
            OrganizationPhotoInline,
            SocialMediaInline,
            organizationAmenityInline,
            OrganizationTimeSlotInline,
            MembershipPlanInline,
        ]

    def get_list_display(self, request):
        """Restricted staff see a simpler list."""
        if request.user.is_superuser:
            return self.list_display
        return ['name', 'email', 'phone_number', 'active']

    # ── Queryset filtering ──

    def get_queryset(self, request):
        """
        Superusers: see everything.
        Restricted staff (Organization Editor group): see ALL organizations.
        They can only edit allowed fields (name, phone, email, location, etc.)
        so it's safe to show all orgs.
        """
        qs = super().get_queryset(request)
        if request.user.is_superuser:
            return qs

        # Staff users in 'Organization Editor' group can see all orgs
        # (field-level restrictions already prevent them from editing sensitive data)
        if request.user.is_staff and request.user.has_perm('fitnesscenter.change_organization'):
            return qs

        # Fallback: show nothing (safest default for unknown users)
        return qs.none()

    # ── Permissions ──

    def has_add_permission(self, request):
        """Only superusers can add new organizations."""
        return request.user.is_superuser

    def has_delete_permission(self, request, obj=None):
        """Only superusers can delete organizations."""
        return request.user.is_superuser

    def has_module_permission(self, request):
        """Both superusers and staff with fitnesscenter permissions can see the module."""
        if request.user.is_superuser:
            return True
        if request.user.is_staff and request.user.has_perm('fitnesscenter.change_organization'):
            return True
        return False

    def has_change_permission(self, request, obj=None):
        """Allow change if superuser or if user has the permission."""
        if request.user.is_superuser:
            return True
        return request.user.has_perm('fitnesscenter.change_organization')


class EmiPlanInline(admin.TabularInline):
    model = EmiPlan
    extra = 1
    fields = ('number_of_installments', 'emi_amount_per_cycle')
    readonly_fields = ('total_emi_amount', 'emi_name', 'razorpay_plan_id')


@admin.register(MembershipPlan)
class MembershipPlanAdmin(admin.ModelAdmin):
    inlines = [EmiPlanInline]
    list_display = ['name', 'organization', 'package_type', 'actual_price', 'offer_price', 'is_active']
    list_filter = ['package_type', 'is_active']
    search_fields = ['name', 'organization__name']
    ordering = ['-created_at']

    def has_module_permission(self, request):
        """Only superusers can see MembershipPlan in admin."""
        if request.user.is_superuser:
            return True
        return False


@admin.register(EmiPlan)
class EmiPlanAdmin(admin.ModelAdmin):
    list_display = ['membership_plan', 'emi_name', 'number_of_installments', 'emi_amount_per_cycle', 'total_emi_amount']
    search_fields = ['membership_plan__name', 'emi_name']
    ordering = ['membership_plan', 'number_of_installments']

    def has_module_permission(self, request):
        """Only superusers can see EmiPlan in admin."""
        if request.user.is_superuser:
            return True
        return False


@admin.register(BankAccountDetails)
class BankAccountDetailsAdmin(admin.ModelAdmin):
    list_display = ['organization', 'account_holder_name', 'account_number', 'ifsc_code', 'bank_name', 'razorpay_account_status']
    search_fields = ['organization__name', 'account_holder_name', 'account_number']
    list_filter = ['business_type', 'razorpay_account_status']

    def has_module_permission(self, request):
        """Only superusers can see BankAccountDetails in admin."""
        if request.user.is_superuser:
            return True
        return False


from apps.fitnesscenter.models import PromotionalBanner

@admin.register(PromotionalBanner)
class PromotionalBannerAdmin(admin.ModelAdmin):
    list_display = ['title', 'organization', 'trainer', 'banner_type', 'is_active', 'created_at']
    list_filter = ['banner_type', 'is_active', 'created_at']
    search_fields = ['title', 'organization__name', 'trainer__first_name', 'trainer__last_name']
    ordering = ['-created_at']

