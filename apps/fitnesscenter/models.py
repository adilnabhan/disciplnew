from django.db import models
from django.conf import settings
from django.utils.text import slugify
import uuid
from django.contrib.gis.db.models import PointField

from apps.utils.create_razorpay_plan import create_razorpay_base_plan, create_razorpay_plan



class Category(models.Model):
    """Model for organization category"""
    name = models.CharField(max_length=100)
    logo = models.ImageField(upload_to="category/", default="")
    is_active = models.BooleanField(default=True)
    display_order = models.PositiveIntegerField(default=1)

    def __str__(self):
        return self.name

    class Meta:
        ordering = ["display_order"]

    @property
    def status_string(self):
        return "ACTIVE" if self.is_active else "INACTIVE"
    
    
class Amenity(models.Model):
    """Model for organization amenities"""
    name = models.CharField(max_length=100, unique=True)
    logo = models.ImageField(upload_to="amenities/", default="")
    display_order = models.PositiveIntegerField(default=1)
    
    def __str__(self):
        return self.name
        
    class Meta:
        verbose_name_plural = "Amenities"
    
    
class Organization(models.Model):
    """Model for gym/fitness etc center organization details"""

    UNREGISTERED = 'unregistered'  # Added by admin, no user account
    REGISTERED = 'registered'      # Gym owner has registered and created account
    VERIFIED = 'verified'          # Bank account added and Razorpay verified

    REGISTRATION_STATUS_CHOICES = [
        (UNREGISTERED, 'Unregistered'),
        (REGISTERED, 'Registered'),
        (VERIFIED, 'Verified'),
    ]

    name = models.CharField(max_length=100)
    mentor = models.ForeignKey(
        'mentors.MentorProfile',
        on_delete=models.SET_NULL,
        related_name='organizations',
        null=True,
        blank=True,
    )
    registration_status = models.CharField(
        max_length=20,
        choices=REGISTRATION_STATUS_CHOICES,
        default=UNREGISTERED,
        db_index=True,
    )
    category = models.ManyToManyField('Category', related_name='organizationcategory')
    logo = models.ImageField(upload_to='organization_logos/', null=True, blank=True)
    description = models.TextField()
    email = models.EmailField()
    phone_number = models.CharField(max_length=15)
    slug = models.SlugField(unique=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_public = models.BooleanField(default=False)
    active = models.BooleanField(default=False)
    is_subscribed = models.BooleanField(default=False)
    take_free_trial = models.BooleanField(default=False)
    is_on_free_trial = models.BooleanField(default=False)
    profile_completeness = models.PositiveIntegerField(default=0, help_text="Profile completeness percentage")
    
    birthday_wish_message = models.TextField(
        null=True, blank=True, help_text="Default birthday message to show to users"
    )
    anniversary_wish_message = models.TextField(
        null=True, blank=True, help_text="Default anniversary message to show to users"
    )
    
    review_count = models.PositiveIntegerField(default=0)
    average_rating = models.FloatField(default=0.0)
    is_slot_available = models.BooleanField(default=True)

    def save(self, *args, **kwargs):
        if not self.slug:
            base_slug = slugify(self.name)
            slug = base_slug
            counter = 1
            while Organization.objects.filter(slug=slug).exclude(id=self.id).exists():
                slug = f"{base_slug}-{counter}"
                counter += 1
            self.slug = slug
        # Auto-update registration_status
        if self.mentor_id and self.registration_status == self.UNREGISTERED:
            self.registration_status = self.REGISTERED
        super().save(*args, **kwargs)
        
    def get_current_subscription(self):
        return self.subscriptions.filter(status='Active').order_by('-start_date').first()

    def __str__(self):
        return self.name
    
    
class Location(models.Model):
    """Model for gym location details"""
    organization = models.OneToOneField(
        Organization,
        on_delete=models.CASCADE,
        related_name='location'
    )
    building_name = models.CharField(max_length=100)
    street = models.CharField(max_length=200)
    city = models.CharField(max_length=100)
    state = models.CharField(max_length=100)
    pin_code = models.CharField(max_length=10)
    latitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    longitude = models.DecimalField(max_digits=9, decimal_places=6, null=True, blank=True)
    location = PointField(null=True, blank=True)
    google_maps_url = models.URLField(max_length=500, null=True, blank=True)
    
    def __str__(self):
        return f"{self.organization.name} - {self.city}"


class WorkingDay(models.Model):
    """Model for gym working days"""
    DAY_CHOICES = [
        ('sun', 'Sunday'),
        ('mon', 'Monday'),
        ('tue', 'Tuesday'),
        ('wed', 'Wednesday'),
        ('thu', 'Thursday'),
        ('fri', 'Friday'),
        ('sat', 'Saturday'),
    ]
    
    organization = models.ForeignKey(
        Organization,
        on_delete=models.CASCADE,
        related_name='working_days'
    )
    day = models.CharField(max_length=3, choices=DAY_CHOICES)
    is_open = models.BooleanField(default=False)
    morning_opening_time = models.TimeField(null=True, blank=True)
    morning_closing_time = models.TimeField(null=True, blank=True)
    evening_opening_time = models.TimeField(null=True, blank=True)
    evening_closing_time = models.TimeField(null=True, blank=True)
    ladies_opening_time = models.TimeField(null=True, blank=True)
    ladies_closing_time = models.TimeField(null=True, blank=True)
    
    class Meta:
        unique_together = ('organization', 'day')
        
    def __str__(self):
        return f"{self.get_day_display()} - {self.organization.name}"


class organizationAmenity(models.Model):
    """Model for mapping amenities to organizations"""
    organization = models.ForeignKey(
        Organization,
        on_delete=models.CASCADE,
        related_name='amenities'
    )
    amenity = models.ForeignKey(
        Amenity,
        on_delete=models.CASCADE,
        related_name='organizations'
    )
    
    def __str__(self):
        return f"{self.amenity.name} - {self.organization.name}"
        
    class Meta:
        unique_together = ('organization', 'amenity')
        verbose_name_plural = "Organization Amenities"
        
        
class OrganizationPhoto(models.Model):
    """Model for gym photos/gallery"""
    organization = models.ForeignKey(
        Organization,
        on_delete=models.CASCADE,
        related_name='photos'
    )
    image = models.ImageField(upload_to='gym_photos/')
    caption = models.CharField(max_length=200, blank=True, null=True)
    is_primary = models.BooleanField(default=False)
    uploaded_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"Photo {self.id} - {self.organization.name}"


class SocialMedia(models.Model):
    """Model for gym social media links"""
    PLATFORM_CHOICES = [
        ('facebook', 'Facebook'),
        ('instagram', 'Instagram'),
        ('twitter', 'Twitter'),
        ('youtube', 'YouTube'),
        ('whatsapp', 'WhatsApp'),
        ('website', 'Website'),
    ]
    
    organization = models.ForeignKey(
        Organization,
        on_delete=models.CASCADE,
        related_name='social_media'
    )
    platform = models.CharField(max_length=20, choices=PLATFORM_CHOICES)
    url = models.CharField(max_length=500, null=True, blank=True)
    
    def __str__(self):
        return f"{self.get_platform_display()} - {self.organization.name}"
        
    class Meta:
        unique_together = ('organization', 'platform')
        verbose_name_plural = "Social Media Links"


class MembershipPlan(models.Model):
    """Model for gym subscription packages"""
    
    MONTHLY = 'Monthly Plan'
    QUARTERLY = 'Quarterly Plan'
    HALF_YEARLY = '6 Month Plan'
    YEARLY = 'Yearly Plan'
    CUSTOM = 'Custom Plan'

        
    PACKAGE_TYPE_CHOICES = [
        (MONTHLY, 'Monthly Plan'),
        (QUARTERLY, 'Quarterly Plan'),
        (HALF_YEARLY, '6 Month Plan'),
        (YEARLY, 'Yearly Plan'),
        (CUSTOM, 'Custom Plan'),
    ]
    
    organization = models.ForeignKey(
        Organization,
        on_delete=models.CASCADE,
        related_name='packages'
    )
    package_type = models.CharField(max_length=20, choices=PACKAGE_TYPE_CHOICES)
    name = models.CharField(max_length=100, null=True, blank=True)
    description = models.TextField(null=True, blank=True)
    actual_price = models.DecimalField(max_digits=10, decimal_places=2)
    offer_price = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    duration_days = models.PositiveIntegerField(null=True, blank=True)
    features = models.JSONField(default=list, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_emi_available = models.BooleanField(default=False)
    razorpay_plan_id = models.CharField(max_length=255, blank=True, null=True)
    

    def save(self, *args, **kwargs):
    # If the plan is free (0 or None), skip Razorpay completely
        offer_price = self.offer_price or 0

        if offer_price > 0:
            # Razorpay expects amount >= ₹1
            success, error = create_razorpay_base_plan(self)
            if not success:
                import logging
                logging.getLogger(__name__).warning(f"Failed to create/update Razorpay plan: {error}")
        
        # Save the plan as usual
        super().save(*args, **kwargs)


    def __str__(self):
        return f"{self.get_package_type_display()} - {self.organization.name}"
    



class EmiPlan(models.Model):
    """Model for installment options for a MembershipPlan"""

    # Link to the main MembershipPlan
    membership_plan = models.ForeignKey(
        MembershipPlan,
        on_delete=models.CASCADE,
        related_name='emi_plans'
    )
    
    emi_name = models.CharField(max_length=100) # e.g., "3-Month EMI Plan"
    number_of_installments = models.PositiveIntegerField()
    emi_amount_per_cycle = models.DecimalField(max_digits=10, decimal_places=2)
    # The total amount the user will pay if they choose this EMI plan
    total_emi_amount = models.DecimalField(max_digits=10, decimal_places=2) 
    
    razorpay_plan_id = models.CharField(max_length=255, blank=True, null=True)

    def save(self, *args, **kwargs):
        # Automatically calculate total EMI amount on save
        self.total_emi_amount = self.number_of_installments * self.emi_amount_per_cycle
        success, error = create_razorpay_plan(self)
        if not success:
            import logging
            logging.getLogger(__name__).warning(f"Failed to create/update Razorpay plan: {error}")
        super().save(*args, **kwargs)
        
    def __str__(self):
        return f"{self.membership_plan.name} - {self.emi_name}"


class BankAccountDetails(models.Model):
    """Model for gym bank account details for Razorpay Route onboarding"""

    # ============================
    # ACCOUNT STATUS
    # ============================
    VERIFICATION_FAILED = 'Verification_Failed'
    ACTIVATED = 'Activated'
    NOT_ACTIVATED = 'Not_Activated'
    VERIFICATION_PENDING = 'Verification_Pending'

    STATUS_CHOICES = (
        (VERIFICATION_FAILED, 'Verification Failed'),
        (ACTIVATED, 'Activated'),
        (NOT_ACTIVATED, 'Not Activated'),
        (VERIFICATION_PENDING, 'Verification Pending'),
    )

    # ============================
    # BUSINESS TYPE
    # ============================
    INDIVIDUAL = 'individual'
    SOLE_PROPRIETORSHIP = 'sole_proprietorship'
    PARTNERSHIP = 'partnership'
    PVT_LTD = 'pvt_ltd'
    LIMITED = 'limited'
    NOT_YET_REGISTERED = 'not_yet_registered'

    BUSINESS_TYPE_CHOICES = (
        (INDIVIDUAL, 'Individual'),
        (SOLE_PROPRIETORSHIP, 'Sole Proprietorship'),
        (PARTNERSHIP, 'Partnership'),
        (PVT_LTD, 'Private Limited'),
        (LIMITED, 'Limited'),
        (NOT_YET_REGISTERED, 'Not Yet Registered'),
    )

    # ============================
    # RELATION
    # ============================
    organization = models.OneToOneField(
        Organization,
        on_delete=models.CASCADE,
        related_name='bank_details'
    )

    # ============================
    # BANK DETAILS
    # ============================
    account_holder_name = models.CharField(max_length=100)
    account_number = models.CharField(max_length=50)
    ifsc_code = models.CharField(max_length=20)
    bank_name = models.CharField(max_length=100)
    branch_name = models.CharField(max_length=100)

    # ============================
    # KYC DETAILS
    # ============================
    pan_number = models.CharField(max_length=10, null=True, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)
    # For companies you may use incorporation_date instead

    business_type = models.CharField(
        max_length=50,
        choices=BUSINESS_TYPE_CHOICES,
        default=INDIVIDUAL,
        null=True,
        blank=True,
    )

    # ============================
    # RAZORPAY LINKED ACCOUNT DATA
    # ============================
    razorpay_account_id = models.CharField(max_length=100, null=True, blank=True)
    razorpay_stakeholder_id = models.CharField(max_length=100, null=True, blank=True)
    razorpay_product_id = models.CharField(max_length=100, null=True, blank=True)

    razorpay_account_status = models.CharField(
        max_length=25,
        choices=STATUS_CHOICES,
        default=NOT_ACTIVATED
    )

    razorpay_error_details = models.TextField(null=True, blank=True)

    activated_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"{self.organization.name} - {self.bank_name}"


from django.db.models.signals import post_save
from django.dispatch import receiver

@receiver(post_save, sender=BankAccountDetails)
def update_org_verified_status(sender, instance, **kwargs):
    if instance.razorpay_account_status == BankAccountDetails.ACTIVATED:
        Organization.objects.filter(pk=instance.organization_id).update(
            registration_status=Organization.VERIFIED
        )


class OrganizationTimeSlot(models.Model):
    """Model for custom time slots for gyms"""
    organization = models.ForeignKey(
        Organization,
        on_delete=models.CASCADE,
        related_name='time_slots'
    )
    name = models.CharField(max_length=100, help_text="e.g., Morning, Evening, Special Batch")
    start_time = models.TimeField()
    end_time = models.TimeField()
    is_active = models.BooleanField(default=True)
    start_date = models.DateField(null=True, blank=True, help_text="Optional start date when this slot becomes active")
    end_date = models.DateField(null=True, blank=True, help_text="Optional end date when this slot ceases to be active")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    @property
    def is_currently_active(self):
        if not self.is_active:
            return False
        from django.utils import timezone
        today = timezone.localdate()
        if self.start_date and today < self.start_date:
            return False
        if self.end_date and today > self.end_date:
            return False
        return True

    def __str__(self):
        return f"{self.name} ({self.start_time} - {self.end_time}) - {self.organization.name}"


class PromotionalBanner(models.Model):
    """Model for dynamic gym/trainer-specific promotional banners"""
    
    BANNER_TYPE_CHOICES = (
        ('promotional', 'Promotional'),
        ('workout_log', 'Workout Log Page'),
        ('global', 'Global/System'),
    )

    organization = models.ForeignKey(
        Organization,
        on_delete=models.CASCADE,
        related_name='promotional_banners',
        null=True,
        blank=True
    )
    trainer = models.ForeignKey(
        'trainer.Trainer',
        on_delete=models.CASCADE,
        related_name='promotional_banners',
        null=True,
        blank=True
    )
    title = models.CharField(max_length=255)
    image = models.ImageField(upload_to='banners/', null=True, blank=True)
    image_url = models.URLField(max_length=500, null=True, blank=True, help_text="Direct link to banner image if no file is uploaded")
    banner_type = models.CharField(max_length=20, choices=BANNER_TYPE_CHOICES, default='promotional')
    target_screen = models.CharField(max_length=100, blank=True, null=True, help_text="Optional target screen identifier for deep linking")
    external_link = models.URLField(max_length=500, blank=True, null=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        owner = self.organization.name if self.organization else (self.trainer.first_name if self.trainer else "System")
        return f"{self.title} ({owner} - {self.banner_type})"


class GymEquipment(models.Model):
    """Maps equipment available at a specific gym organization."""
    organization = models.ForeignKey(
        Organization,
        on_delete=models.CASCADE,
        related_name='gym_equipments'
    )
    equipment = models.ForeignKey(
        'trainer.Equipment',
        on_delete=models.CASCADE
    )
    is_functional = models.BooleanField(default=True, help_text="Set to False if the equipment is temporarily out of order")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('organization', 'equipment')
        verbose_name_plural = "Gym Equipment Inventory"

    def __str__(self):
        return f"{self.equipment.name} @ {self.organization.name}"

