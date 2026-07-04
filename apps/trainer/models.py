from django.db import models


class Trainer(models.Model):

    GENDER_CHOICES = (
        ('male', 'Male'),
        ('female', 'Female'),
        ('other', 'Other'),
    )

    USER_TYPE_CHOICES = (
        ('trainer', 'Trainer'),
        ('dietitian', 'Dietitian'),
    )

    user = models.OneToOneField(
        'user.User',
        on_delete=models.CASCADE,
        related_name='trainer_profile',
        null=True,
        blank=True
    )

    user_type = models.CharField(max_length=20, choices=USER_TYPE_CHOICES, default='trainer')

    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)

    email = models.EmailField(max_length=150, unique=True, null=True, blank=True)
    mobile = models.CharField(max_length=20, unique=True, null=True, blank=True)

    gender = models.CharField(max_length=10, choices=GENDER_CHOICES, null=True, blank=True)
    date_of_birth = models.DateField(null=True, blank=True)

    profile_image = models.ImageField(upload_to='trainers/profile/', null=True, blank=True)

    experience_years = models.IntegerField(default=0)

    bio = models.TextField(blank=True)

    is_freelancer = models.BooleanField(default=False)
    join_gym = models.BooleanField(default=False)
    event_collaborator = models.BooleanField(default=False)

    expected_pay_min = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    expected_pay_max = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)

    profile_step = models.IntegerField(default=1)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class TrainerProfessionalDetails(models.Model):

    trainer = models.OneToOneField(
        Trainer,
        on_delete=models.CASCADE,
        related_name="professional_details"
    )

    years_of_experience = models.IntegerField()

    specialisations = models.TextField(blank=True, null=True)

    bio = models.TextField(blank=True, null=True)

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

class TrainerExperience(models.Model):

    trainer = models.ForeignKey(
        Trainer,
        on_delete=models.CASCADE,
        related_name="experiences"
    )

    organization_name = models.CharField(max_length=255)
    designation = models.CharField(max_length=255)

    start_date = models.DateField()
    end_date = models.DateField(null=True, blank=True)

    currently_working = models.BooleanField(default=False)

    description = models.TextField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

class Specialization(models.Model):

    USER_TYPE_CHOICES = (
        ('trainer', 'Trainer'),
        ('dietitian', 'Dietitian'),
    )

    name = models.CharField(max_length=150)
    user_type = models.CharField(max_length=20, choices=USER_TYPE_CHOICES, default='trainer')

    def __str__(self):
        return f"{self.name} ({self.user_type})"


class TrainerSpecialization(models.Model):

    trainer = models.ForeignKey(
        Trainer,
        on_delete=models.CASCADE
    )

    specialization = models.ForeignKey(
        Specialization,
        on_delete=models.CASCADE
    )


class TrainerCertification(models.Model):

    trainer = models.ForeignKey(
        Trainer,
        on_delete=models.CASCADE
    )

    certificate_name = models.CharField(max_length=200)

    certificate_file = models.FileField(
        upload_to="trainer/certifications/"
    )

    issued_by = models.CharField(max_length=200, blank=True)

    issued_date = models.DateField(
        null=True,
        blank=True
    )


class TrainerPortfolio(models.Model):

    TYPE_CHOICES = (
        ('result', 'Result'),
        ('workout', 'Workout'),
        ('achievement', 'Achievement'),
    )

    trainer = models.ForeignKey(
        Trainer,
        on_delete=models.CASCADE
    )

    image = models.CharField(max_length=255)

    type = models.CharField(
        max_length=20,
        choices=TYPE_CHOICES
    )


class TrainerTransformation(models.Model):

    trainer = models.ForeignKey(
        Trainer,
        on_delete=models.CASCADE
    )

    before_image = models.CharField(max_length=255)

    after_image = models.CharField(max_length=255)

    description = models.TextField(blank=True)


class Language(models.Model):

    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name


class TrainerLanguage(models.Model):

    trainer = models.ForeignKey(
        Trainer,
        on_delete=models.CASCADE
    )

    language = models.ForeignKey(
        Language,
        on_delete=models.CASCADE
    )


class TrainerSocialLink(models.Model):

    trainer = models.ForeignKey(
        Trainer,
        on_delete=models.CASCADE
    )

    website = models.CharField(max_length=255, blank=True, null=True, default='')
    whatsapp = models.CharField(max_length=20, blank=True, null=True, default='')
    instagram = models.CharField(max_length=255, blank=True, null=True, default='')
    facebook = models.CharField(max_length=255, blank=True, null=True, default='')
    youtube = models.CharField(max_length=255, blank=True, null=True, default='')


class Location(models.Model):

    trainer = models.ForeignKey(
        Trainer,
        on_delete=models.CASCADE
    )

    street = models.CharField(max_length=255)

    area = models.CharField(max_length=255, blank=True, null=True)

    city = models.CharField(max_length=100)

    state = models.CharField(max_length=100)

    country = models.CharField(max_length=100, default='India', blank=True)

    pincode = models.CharField(max_length=10)

    latitude = models.DecimalField(
        max_digits=10,
        decimal_places=7,
        null=True,
        blank=True
    )

    longitude = models.DecimalField(
        max_digits=10,
        decimal_places=7,
        null=True,
        blank=True
    )

    created_at = models.DateTimeField(auto_now_add=True)

    updated_at = models.DateTimeField(auto_now=True)


class TrainerBankAccount(models.Model):
    trainer = models.ForeignKey(
        Trainer,
        on_delete=models.CASCADE,
        related_name="bank_accounts"
    )

    account_holder_name = models.CharField(max_length=255)
    account_number = models.CharField(max_length=50)
    ifsc_code = models.CharField(max_length=20)

    pan_number = models.CharField(max_length=20, null=True, blank=True)
    business_type = models.CharField(max_length=50, default="individual")

    # Razorpay fields
    razorpay_account_id = models.CharField(max_length=100, null=True, blank=True)
    razorpay_product_id = models.CharField(max_length=100, null=True, blank=True)
    razorpay_stakeholder_id = models.CharField(max_length=100, null=True, blank=True)

    razorpay_account_status = models.CharField(
        max_length=50,
        default="verification_pending"
    )

    created_at = models.DateTimeField(auto_now_add=True)

class TrainerPlan(models.Model):

    trainer = models.ForeignKey(
        Trainer,
        on_delete=models.CASCADE
    )

    plan_name = models.CharField(max_length=255)

    description = models.TextField(blank=True, null=True)

    price = models.DecimalField(max_digits=10, decimal_places=2)

    offer_price = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True
    )

    duration_days = models.IntegerField()

    emi_available = models.BooleanField(default=False)

    max_clients = models.IntegerField(null=True, blank=True)

    is_active = models.BooleanField(default=True)

    created_at = models.DateTimeField(auto_now_add=True)

    updated_at = models.DateTimeField(auto_now=True)

class TrainerLocationPreference(models.Model):

    trainer = models.ForeignKey(
        Trainer,
        on_delete=models.CASCADE,
        related_name='location_preferences'
    )

    location_name = models.CharField(max_length=255)

    created_at = models.DateTimeField(auto_now_add=True)

class TrainerSubscriptionPlan(models.Model):
    """Discipl subscription plans available for trainers (mirrors DisciplSubscriptionPlan for orgs)"""

    MONTHLY = 'Monthly Plan'
    HALF_YEARLY = '6 Month Plan'

    PLAN_TYPES = (
        ('MONTHLY', 'Monthly Plan'),
        ('HALF_YEARLY', '6 Month Plan'),
    )

    name = models.CharField(max_length=100)
    plan_type = models.CharField(max_length=20, choices=PLAN_TYPES)
    regular_price = models.DecimalField(max_digits=10, decimal_places=2)
    discounted_price = models.DecimalField(max_digits=10, decimal_places=2)
    total_cost = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    savings = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    period = models.PositiveIntegerField(help_text='Duration in months')
    description = models.TextField(blank=True)
    features = models.JSONField(default=list, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} (₹{self.discounted_price}/month)"


class TrainerSubscription(models.Model):

    TRIAL = 'Trial'
    ACTIVE = 'Active'
    EXPIRED = 'Expired'
    CANCELLED = 'Cancelled'
    PENDING = 'Pending'

    STATUS_CHOICES = (
        (TRIAL, 'Trial'),
        (ACTIVE, 'Active'),
        (EXPIRED, 'Expired'),
        (CANCELLED, 'Cancelled'),
        (PENDING, 'Pending'),
    )

    trainer = models.ForeignKey(Trainer, on_delete=models.CASCADE, related_name='subscriptions')
    plan = models.ForeignKey(TrainerSubscriptionPlan, on_delete=models.PROTECT)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')
    paid_amount = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)

    razorpay_order_id = models.CharField(max_length=255, null=True, blank=True)
    razorpay_payment_id = models.CharField(max_length=255, null=True, blank=True)

    start_date = models.DateTimeField(null=True, blank=True)
    end_date = models.DateTimeField(null=True, blank=True)

    payment_status = models.CharField(
        max_length=20,
        choices=[('pending', 'Pending'), ('completed', 'Completed'), ('failed', 'Failed')],
        default='pending'
    )

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)


from .workout_models import (
    MuscleGroup,
    WorkoutGroup,
    Equipment,
    ProgramGoal,
    DifficultyLevel,
    Workout,
    WorkoutMuscle,
    GymWorkoutOverride,
    TrainerWorkoutOverride,
    WorkoutPlan,
    WorkoutPlanWeek,
    WorkoutPlanDay,
    WorkoutPlanExercise,
    ExerciseSetTemplate,
    CustomerWorkoutPlan,
    WorkoutSession,
    WorkoutLog,
    ExerciseSetLog,
    PRRecord,
)


class OrganizationTrainerLink(models.Model):
    """Link request from a Trainer/Dietitian to join an Organization."""

    PENDING = 'pending'
    APPROVED = 'approved'
    REJECTED = 'rejected'

    STATUS_CHOICES = (
        (PENDING, 'Pending'),
        (APPROVED, 'Approved'),
        (REJECTED, 'Rejected'),
    )

    trainer = models.ForeignKey(
        Trainer,
        on_delete=models.CASCADE,
        related_name='organization_links'
    )
    organization = models.ForeignKey(
        'fitnesscenter.Organization',
        on_delete=models.CASCADE,
        related_name='trainer_links'
    )
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default=PENDING)
    invited_by_org = models.BooleanField(default=False, help_text='True if gym sent the invite, False if trainer requested')
    requested_at = models.DateTimeField(auto_now_add=True)
    responded_at = models.DateTimeField(null=True, blank=True)
    rejection_reason = models.TextField(null=True, blank=True)

    class Meta:
        unique_together = ('trainer', 'organization')

    def __str__(self):
        return f"{self.trainer} → {self.organization} ({self.status})"


class TrainerReview(models.Model):
    """Review and rating given to a trainer by a customer."""

    trainer = models.ForeignKey(
        Trainer,
        on_delete=models.CASCADE,
        related_name='reviews'
    )
    customer = models.ForeignKey(
        'customers.Customer',
        on_delete=models.CASCADE,
        related_name='trainer_reviews'
    )
    rating = models.PositiveSmallIntegerField(
        help_text='Rating out of 5'
    )
    comment = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('trainer', 'customer')

    def __str__(self):
        return f"{self.customer} → {self.trainer} ({self.rating}/5)"
