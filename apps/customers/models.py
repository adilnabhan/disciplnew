from django.conf import settings
from django.db import models
from django_extensions.db.fields import (
    CreationDateTimeField,
    ModificationDateTimeField,
)

from phonenumber_field.modelfields import PhoneNumberField
from django.contrib.postgres.fields import ArrayField

from apps.fitnesscenter.models import EmiPlan, MembershipPlan, Organization
from apps.utils.mobilenumber import hash_contact_number
from datetime import date

class FitnessLevel(models.TextChoices):
    BEGINNER = 'Beginner', 'Just starting out'
    INTERMEDIATE = 'Intermediate', 'Working out regularly'
    ADVANCED = 'Advanced', 'Training intensely'


class StressLevel(models.TextChoices):
    NONE = 'None', 'None'
    MILD = 'Mild', 'Mild'
    MODERATE = 'Moderate', 'Moderate'
    HIGH = 'High', 'High'
    SEVERE = 'Severe', 'Severe'


class WeightGoal(models.TextChoices):
    LOSE = 'Lose', 'Lose'
    GAIN = 'Gain', 'Gain'
    MAINTAIN = 'Maintain', 'Maintain'


class SleepGoal(models.TextChoices):
    HOURS_4_5 = '4-5_hours', '4 - 5 Hours'
    HOURS_5_6 = '5-6_hours', '5 - 6 Hours'
    HOURS_6_7 = '6-7_hours', '6 - 7 Hours'
    HOURS_7_8 = '7-8_hours', '7 - 8 Hours'
    HOURS_8_9 = '8-9_hours', '8 - 9 Hours'
    ABOVE_9 = 'Above_9_hours', 'Above 9 Hours'


class Profession(models.TextChoices):
    STUDENT = 'Student', 'Student'
    SOFTWARE_ENGINEER = 'Software_Engineer', 'Software Engineer'
    DOCTOR = 'Doctor', 'Doctor'
    NURSE = 'Nurse', 'Nurse'
    TEACHER = 'Teacher', 'Teacher'
    BUSINESS_OWNER = 'Business_Owner', 'Business Owner'
    FREELANCER = 'Freelancer', 'Freelancer'
    HOME_MAKER = 'Home_Maker', 'Home Maker'
    GOVERNMENT_EMPLOYEE = 'Government_Employee', 'Government Employee'
    CORPORATE_EMPLOYEE = 'Corporate_Employee', 'Corporate Employee'
    ARMED_FORCES = 'Armed_Forces', 'Armed Forces'
    ATHLETE = 'Athlete', 'Athlete'
    TRAINER = 'Trainer', 'Trainer'
    OTHER = 'Other', 'Other'

class JobSatisfaction(models.IntegerChoices):
    VERY_HAPPY = 5, 'Very Happy'
    HAPPY = 4, 'Happy'
    NEUTRAL = 3, 'Neutral'
    UNHAPPY = 2, 'Unhappy'
    VERY_UNHAPPY = 1, 'Very Unhappy'


class WorkingHours(models.TextChoices):
    LESS_THAN_4 = '<4_hours', '< 4 Hours'
    BETWEEN_4_6 = '4-6_hours', '4 - 6 Hours'
    BETWEEN_6_8 = '6-8_hours', '6 - 8 Hours'
    BETWEEN_8_10 = '8-10_hours', '8 - 10 Hours'
    ABOVE_10 = '10+_hours', '10+ Hours'


class TargetGoal(models.TextChoices):
    BUILD_MUSCLE = 'Build_Muscle', 'Build Muscle'
    LOSS_WEIGHT = 'Loss_Weight', 'Loss Weight'
    WEIGHT_GAIN = 'Gain_Weight', 'Gain Weight'
    STAY_CONSISTENT = 'Stay_Consistent', 'Stay Consistent'
    IMPROVE_STAMINA = 'Improve_Stamina', 'Improve Stamina'
    IMPROVE_ENDURANCE = 'Improve_Endurance', 'Improve Endurance'
    INCREASE_FLEXIBILITY = 'Increase_Flexibility', 'Increase Flexibility'
    GENERAL_FITNESS = 'General_Fitness', 'General Fitness'
    OTHER = 'Other', 'Other'


class HealthCondition(models.TextChoices):
    DIABETES = 'Diabetes', 'Diabetes'
    HYPERTENSION = 'Hypertension', 'Hypertension'
    HEART_DISEASE = 'Heart_Disease', 'Heart Disease'
    ASTHMA = 'Asthma', 'Asthma'
    OBESITY = 'Obesity', 'Obesity'
    ARTHRITIS = 'Arthritis', 'Arthritis'
    DEPRESSION = 'Depression', 'Depression'
    OTHER = 'Other', 'Other'


class Injury(models.Model):
    name = models.CharField(max_length=100, unique=True)
    display_order = models.PositiveIntegerField(default=1)
    is_active = models.BooleanField(default=True)
    
    def __str__(self): 
        return self.name

class MedicalCondition(models.Model):
    name = models.CharField(max_length=100, unique=True)
    display_order = models.PositiveIntegerField(default=1)
    is_active = models.BooleanField(default=True)
    
    def __str__(self): 
        return self.name

class Customer(models.Model):
    """
    Customer Profile.
    """

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, on_delete=models.SET_NULL,
        null=True,
        related_name='customer',
    )
    hash_of_user_phone_number = models.CharField(max_length=128, null=True, blank=True)
    created_by = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True, blank=True, related_name='created_customers')
    emergency_contact_name = models.CharField(max_length=100, null=True, blank=True)
    emergency_contact_number = PhoneNumberField(null=True, blank=True)
    height = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True, help_text="Height in cm")
    weight = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True, help_text="Weight in kg")
    profession = models.CharField(max_length=50, choices=Profession.choices, null=True, blank=True)
    other_profession = models.CharField(max_length=100, null=True, blank=True, help_text="Specify if profession is 'Other'")
    is_active_member = models.BooleanField(default=False)
    organization = models.ForeignKey(Organization, on_delete=models.CASCADE, null=True, blank=True)
    trainer = models.ForeignKey('trainer.Trainer', on_delete=models.SET_NULL, null=True, blank=True, related_name='customers')
    trainer_notes = models.TextField(null=True, blank=True, help_text="Notes/remarks added by the trainer")
    trainer_assigned_at = models.DateTimeField(null=True, blank=True, help_text="Timestamp when the trainer was assigned")
    
    # Fitness and Health Details
    fitness_level = models.CharField(max_length=20, choices=FitnessLevel.choices, null=True, blank=True)
    stress_level = models.CharField(max_length=20, choices=StressLevel.choices, null=True, blank=True)
    weight_goal = models.CharField(max_length=20, choices=WeightGoal.choices, null=True, blank=True)
    sleep_goal = models.CharField(max_length=20, choices=SleepGoal.choices, null=True, blank=True)
    target_weight = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True, help_text="Target Weight in kg")
    target_goal = ArrayField(models.CharField(max_length=50, choices=TargetGoal.choices), null=True, blank=True)
    target_goal_other = models.CharField(max_length=100, null=True, blank=True, help_text="Specify if target goal is 'Other'")
    is_healthy = models.BooleanField(default=True, help_text="True if the customer is healthy, False if they have health conditions.")
    health_conditions = ArrayField(models.CharField(max_length=50, choices=HealthCondition.choices), null=True, blank=True)
    health_conditions_other = models.CharField(max_length=100, null=True, blank=True, help_text="Specify if health condition is 'Other'")
    active_scale = models.PositiveIntegerField(null=True, blank=True, help_text="Active Scale score")

    job_satisfaction = models.IntegerField(choices=JobSatisfaction.choices, null=True, blank=True, help_text="How happy are you with your current profession?")
    average_working_hours = models.CharField(max_length=20, choices=WorkingHours.choices, null=True, blank=True, help_text="Average daily working hours")

    average_sleep_hours = models.CharField(max_length=20, choices=SleepGoal.choices, null=True, blank=True, help_text="Average daily sleep hours")
    injuries = models.ManyToManyField('Injury', blank=True, related_name='customers')
    medical_conditions = models.ManyToManyField('MedicalCondition', blank=True, related_name='customers')
    profile_completeness = models.PositiveIntegerField(default=0, help_text="Profile completeness percentage")

    bmi = models.DecimalField(max_digits=5, decimal_places=2,null=True, blank=True, editable=False, help_text="Body Mass Index (auto-calculated)")
    bmr = models.DecimalField(max_digits=6, decimal_places=2, null=True, blank=True, editable=False, help_text="Basal Metabolic Rate (auto-calculated)")
    bf_percentage = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True, editable=False, help_text="Body Fat Percentage (auto-calculated)")

    created = CreationDateTimeField('created', null=True)
    modified = ModificationDateTimeField('modified', null=True)


    def save(self, *args, **kwargs):
        # Check if trainer is being assigned or changed
        if self.pk:
            try:
                orig = Customer.objects.get(pk=self.pk)
                if orig.trainer != self.trainer:
                    if self.trainer:
                        from django.utils import timezone
                        self.trainer_assigned_at = timezone.now()
            except Customer.DoesNotExist:
                pass
        else:
            if self.trainer:
                from django.utils import timezone
                self.trainer_assigned_at = timezone.now()

        try:
            if self.height and self.weight:
                height_cm = float(self.height)
                weight_kg = float(self.weight)
                height_m = height_cm / 100

                # BMI Calculation
                self.bmi = round(weight_kg / (height_m ** 2), 2)

                if self.user and self.user.date_of_birth and self.user.gender:
                    age = self.calculate_age(self.user.date_of_birth)
                    gender = self.user.gender.lower()

                    # BMR Calculation (Mifflin-St Jeor)
                    if gender == 'male':
                        self.bmr = round(10 * weight_kg + 6.25 * height_cm - 5 * age + 5, 2)
                    elif gender == 'female':
                        self.bmr = round(10 * weight_kg + 6.25 * height_cm - 5 * age - 161, 2)
                    else:
                        self.bmr = None

                    # Body Fat % Calculation
                    bf = None
                    if age >= 18:
                        if gender == 'male':
                            bf = 1.20 * self.bmi + 0.23 * age - 16.2
                        elif gender == 'female':
                            bf = 1.20 * self.bmi + 0.23 * age - 5.4
                    else:
                        if gender == 'male':
                            bf = 1.51 * self.bmi - 0.70 * age - 2.2
                        elif gender == 'female':
                            bf = 1.51 * self.bmi - 0.70 * age + 1.4

                    self.bf_percentage = round(bf, 2) if bf is not None else None
                else:
                    self.bmr = None
                    self.bf_percentage = None
            else:
                self.bmi = None
                self.bmr = None
                self.bf_percentage = None

        except (ValueError, ZeroDivisionError):
            self.bmi = None
            self.bmr = None
            self.bf_percentage = None
        super().save(*args, **kwargs) 
        
    
    @staticmethod
    def calculate_age(dob):
        today = date.today()
        return today.year - dob.year - ((today.month, today.day) < (dob.month, dob.day)) 
    
    @property
    def get_account_label(self):
        return f"Customer: {self.user.get_full_name() if self.user else 'Unknown Customer'}"
    
    @property
    def bmi_category(self):
        """Get BMI category based on calculated BMI."""
        if not self.bmi:
            return None
        
        if self.bmi < 18.5:
            return 'underweight'
        elif 18.5 <= self.bmi <= 24.9:
            return 'normal'
        elif 25.0 <= self.bmi <= 29.9:
            return 'overweight'
        else:
            return 'obese'

    def check_and_update_membership_status(self):
        from django.utils import timezone
        now = timezone.now()
        expired_memberships = self.memberships.filter(
            status__in=['Active', 'Trial'],
            end_date__lt=now
        )
        if expired_memberships.exists():
            from apps.communication.notifications import send_push_notification
            for m in expired_memberships:
                # Notify customer
                if self.user:
                    send_push_notification(
                        user=self.user,
                        title="Membership Expired",
                        body="Your membership plan has expired. Please renew your subscription to continue enjoying premium benefits."
                    )
                # Notify trainer
                if self.trainer and self.trainer.user:
                    send_push_notification(
                        user=self.trainer.user,
                        title="Membership Expired",
                        body=f"Membership for {self.user.full_name if self.user else 'your client'} has expired."
                    )
            expired_memberships.update(status='Expired', is_active=False)
        
        has_active = self.memberships.filter(
            status__in=['Active', 'Trial'],
            end_date__gte=now
        ).exists()
        
        if self.is_active_member != has_active:
            self.is_active_member = has_active
            self.save(update_fields=['is_active_member'])
            
        return has_active

    @property
    def body_fat_category(self):
        """Get body fat category based on calculated body fat percentage."""
        if not self.bf_percentage:
            return None
        
        bf = float(self.bf_percentage)
        if bf <= 5:
            return 'essential'
        elif 6 <= bf <= 13:
            return 'athletes'
        elif 14 <= bf <= 17:
            return 'fitness'
        elif 18 <= bf <= 24:
            return 'average'
        else:
            return 'obese'

    @property
    def weight_to_target_diff(self):
        """Calculate difference between current and target weight."""
        if self.weight and self.target_weight:
            return float(self.target_weight) - float(self.weight)
        return None

    @property
    def is_weight_goal_achievable(self):
        """Check if current weight aligns with weight goal."""
        if not (self.weight and self.target_weight and self.weight_goal):
            return None
        
        diff = self.weight_to_target_diff
        if self.weight_goal == 'lose' and diff < 0:
            return True
        elif self.weight_goal == 'gain' and diff > 0:
            return True
        elif self.weight_goal == 'maintain' and abs(diff) <= 2:
            return True
        return False  
    
    
    def get_fitness_level_display_short(self):
        """Get short display name for fitness level."""
        level_map = {
            'beginner': 'Beginner',
            'intermediate': 'Intermediate', 
            'advanced': 'Advanced'
        }
        return level_map.get(self.fitness_level, '')


    def get_medical_conditions_list(self):
        """Get comma-separated list of medical conditions."""
        return ", ".join([condition.name for condition in self.medical_conditions.filter(is_active=True)])

    def get_injuries_list(self):
        """Get comma-separated list of injuries."""
        return ", ".join([injury.name for injury in self.injuries.filter(is_active=True)]) 
        
        

class CustomerMembership(models.Model):
    """Model for customer's membership subscription"""
    
    TRIAL = 'Trial'
    ACTIVE = 'Active'
    EXPIRED = 'Expired'
    CANCELLED = 'Cancelled'
    PENDING = 'Pending'
    HOLD = 'Hold'

    STATUS_CHOICES = (
        (TRIAL, 'Trial'),
        (ACTIVE, 'Active'),
        (EXPIRED, 'Expired'),
        (CANCELLED, 'Cancelled'),
        (PENDING, 'Pending'),
        (HOLD, 'Hold'),
    )
    
    customer = models.ForeignKey(
        Customer,
        on_delete=models.CASCADE,
        related_name='memberships'
    )
    membership = models.ForeignKey(
        MembershipPlan,
        on_delete=models.CASCADE,
        related_name='customer_subscribers'
    )
    
    start_date = models.DateTimeField(null=True, blank=True)
    end_date = models.DateTimeField(null=True, blank=True)
    
    trial_start_at = models.DateTimeField(null=True, blank=True)
    trial_end_at = models.DateTimeField(null=True, blank=True)
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default=PENDING)
    amount = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)

    assign_free = models.BooleanField(default=False)
    is_trial = models.BooleanField(default=False)
    payment_status = models.CharField(max_length=20, choices=[
        ('pending', 'Pending'),
        ('completed', 'Completed'),
        ('failed', 'Failed'),
        ('refunded', 'Refunded')
    ], default='pending')
    razorpay_order_id = models.CharField(max_length=255, null=True, blank=True)
    razorpay_payment_id = models.CharField(max_length=255, null=True, blank=True)
    razorpay_subscription_id = models.CharField(max_length=255, null=True, blank=True)
    
    last_payment_date = models.DateTimeField(null=True, blank=True)
    next_due_date = models.DateTimeField(null=True, blank=True)
    emi_plan = models.ForeignKey(
        EmiPlan,
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    


    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def cancel_subscription(self, reason='Cancelled by user'):
        """Cancel the subscription and update related fields."""
        self.status = self.CANCELLED
        self.is_active = False
        self.payment_status = 'failed'  # Using 'failed' until 'cancelled' status is added
        self.save()

    def hold_subscription(self, reason='Autopay cancelled by user'):
        """Put subscription on hold when autopay is cancelled."""
        self.status = self.HOLD
        self.is_active = False
        self.payment_status = 'pending'
        self.save()

    def __str__(self):
        return f"{self.customer.user.full_name if self.customer.user else 'Unknown'} - {self.membership.name}"


class CustomerMembershipTransaction(models.Model):
    """Model for payment records associated with subscriptions"""
    
    PENDING = 'Pending'
    SUCCESSFUL = 'Successful'
    FAILED = 'Failed'
    REFUNDED = 'Refunded'
    
    PAYMENT_STATUS = (
        (PENDING, 'Pending'),
        (SUCCESSFUL, 'Successful'),
        (FAILED, 'Failed'),
        (REFUNDED, 'Refunded'),
    )
    
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='customer_transaction',  null=True, blank=True)
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE)
    membership = models.ForeignKey(MembershipPlan, on_delete=models.PROTECT, null=True, blank=True)

    subscription = models.ForeignKey(CustomerMembership, on_delete=models.CASCADE, related_name='payments', null=True, blank=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    
    coupon = models.ForeignKey('user.Coupon', on_delete=models.SET_NULL, null=True, blank=True, related_name='customer_transactions')
    
    order_id = models.CharField(max_length=255, help_text="Razorpay Order ID", null=True, blank=True)
    payment_id = models.CharField(max_length=255, help_text="Razorpay Payment ID", null=True, blank=True)
    
    period = models.IntegerField(default=0)
    razorpay_signature = models.CharField(null=True, blank=True, max_length=1000)
    
    status = models.CharField(max_length=20, choices=PAYMENT_STATUS, default='PENDING')
    remarks = models.TextField(null=True, blank=True)
    transfer_status = models.CharField(
        max_length=20,
        choices=[
            ('not_initiated', 'Not Initiated'),
            ('pending', 'Pending'),
            ('successful', 'Successful'),
            ('failed', 'Failed'),
            ('retrying', 'Retrying')
        ],
        default='not_initiated',
        help_text="Status of payment transfer to gym account"
    )

    payment_method = models.CharField(max_length=100, blank=True)
    payment_date = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def mark_success(self):
        self.status = self.SUCCESSFUL
        self.save(update_fields=['status'])

    def mark_failed(self):
        self.status = self.FAILED
        self.save(update_fields=['status'])
    
    def __str__(self):
        if self.user:
            return f"Payment {self.id} for {self.user.username}"
        return f"Payment {self.id} (no user)"

    

class CustomerReview(models.Model):
    organization = models.ForeignKey(Organization, on_delete=models.CASCADE, related_name='reviews')
    customer = models.ForeignKey('customers.Customer', on_delete=models.CASCADE, related_name='reviews', null=True)
    rating = models.PositiveSmallIntegerField()
    comment = models.TextField(blank=True)

    created = CreationDateTimeField()
    modified = ModificationDateTimeField()

    class Meta:
        unique_together = ('organization', 'customer')


class MembershipRequest(models.Model):
    """
    Model for customer membership plan requests.
    Customer requests a membership from a gym (offline onboarding).
    Gym can accept/reject and select which plan to assign.
    """

    PENDING = 'pending'
    ACCEPTED = 'accepted'
    REJECTED = 'rejected'
    CLOSED = 'closed'
    CONTACTED = 'contacted'

    STATUS_CHOICES = (
        (PENDING, 'Pending'),
        (ACCEPTED, 'Accepted'),
        (REJECTED, 'Rejected'),
        (CLOSED, 'Closed'),
        (CONTACTED, 'Contacted'),
    )
    contact_info = models.JSONField(null=True, blank=True, help_text='Gym contact details when proposing a plan')

    PAYMENT_MODE_CHOICES = (
        ('offline', 'Offline'),
        ('online', 'Online'),
    )

    customer = models.ForeignKey(
        Customer,
        on_delete=models.CASCADE,
        related_name='membership_requests'
    )
    organization = models.ForeignKey(
        Organization,
        on_delete=models.CASCADE,
        related_name='membership_requests'
    )
    # Plan the customer wants
    membership_plan = models.ForeignKey(
        MembershipPlan,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='customer_requests',
        help_text="Plan selected by the customer"
    )
    # Plan the gym assigns (may differ from what customer requested)
    selected_plan = models.ForeignKey(
        MembershipPlan,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='gym_assigned_requests',
        help_text="Plan selected/assigned by the gym"
    )

    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default=PENDING
    )
    payment_mode = models.CharField(
        max_length=20,
        choices=PAYMENT_MODE_CHOICES,
        default='offline'
    )

    notes = models.TextField(null=True, blank=True, help_text="Customer notes/remarks")
    gym_remarks = models.TextField(null=True, blank=True, help_text="Gym remarks on acceptance/rejection")

    # Fields set by gym when accepting the request
    accepted_amount = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True,
        help_text="Final amount set by gym"
    )
    discount_amount = models.DecimalField(
        max_digits=10, decimal_places=2, null=True, blank=True,
        help_text="Discount given by gym"
    )
    start_date = models.DateTimeField(
        null=True, blank=True,
        help_text="Membership start date set by gym"
    )
    end_date = models.DateTimeField(
        null=True, blank=True,
        help_text="Membership end date set by gym"
    )
    transaction_number = models.CharField(
        max_length=100, null=True, blank=True,
        help_text="Cash/offline transaction reference number"
    )

    requested_at = models.DateTimeField(auto_now_add=True)
    responded_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ['-requested_at']

    def __str__(self):
        customer_name = self.customer.user.full_name if self.customer.user else 'Unknown'
        return f"Request #{self.id} - {customer_name} → {self.organization.name} ({self.status})"

class CustomerWorkoutPlan(models.Model):
    """Link a workout plan to a customer via an accepted membership request"""
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, related_name='workout_plans')
    workout_plan = models.ForeignKey('trainer.WorkoutPlan', on_delete=models.CASCADE)
    membership_request = models.OneToOneField(MembershipRequest, on_delete=models.CASCADE)
    assigned_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.customer.user.full_name} - {self.workout_plan.name}"


# Import new feature models to register them
from apps.customers.nutrition_models import Food, FoodLog, WaterLog
from apps.customers.body_models import WeightLog, BodyMeasurementLog, ProgressPhoto
from apps.customers.community_models import CommunityPost, CommunityLike, CommunityComment
from apps.customers.achievement_models import Badge, EarnedBadge, CustomerPoints