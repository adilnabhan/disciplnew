import uuid
from django.db import models
from django.conf import settings
from django.utils import timezone

from apps.fitnesscenter.models import Organization

# Create your models here.


class DisciplSubscriptionPlan(models.Model):
    """Model for subscription plans available in the MentorApp"""
    
    MONTHLY = 'Monthly Plan'
    HALF_YEARLY = '6 Month Plan'
        
    PLAN_TYPES = (
        ('MONTHLY', 'Monthly Plan'),
        ('HALF_YEARLY', '6 Month Plan'),
    )
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100)
    plan_type = models.CharField(max_length=20, choices=PLAN_TYPES)
    regular_price = models.DecimalField(max_digits=10, decimal_places=2)
    discounted_price = models.DecimalField(max_digits=10, decimal_places=2)
    total_cost = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    savings = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    period = models.PositiveIntegerField()
    description = models.TextField(blank=True)
    features = models.JSONField(default=list, null=True, blank=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.name} (₹{self.discounted_price}/month)"


class OrganizationSubscriptionsDetails(models.Model):
    """Model for user subscriptions"""
    
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
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='organizationsubscriptions')
    plan = models.ForeignKey(DisciplSubscriptionPlan, on_delete=models.PROTECT)
    organization = models.ForeignKey(
        'fitnesscenter.Organization',
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='subscriptions'
    )
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING')
    paid_amount = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True)
    
    razorpay_order_id = models.CharField(max_length=255, null=True, blank=True)
    razorpay_payment_id = models.CharField(max_length=255, null=True, blank=True)

    start_date = models.DateTimeField(null=True, blank=True)
    end_date = models.DateTimeField(null=True, blank=True)

    trial_start_at = models.DateTimeField(null=True, blank=True)
    trial_end_at = models.DateTimeField(null=True, blank=True)
    
    payment_status = models.CharField(
        max_length=20,
        choices=[('pending', 'Pending'), ('completed', 'Completed'), ('failed', 'Failed')],
        default='pending'
    )
    last_payment_date = models.DateTimeField(null=True, blank=True)
    next_due_date = models.DateTimeField(null=True, blank=True)

    auto_renew = models.BooleanField(default=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)

    @property
    def is_active_now(self):
        now = timezone.now()
        return self.status == self.ACTIVE and self.start_date <= now <= self.end_date

    @property
    def is_trial_now(self):
        now = timezone.now()
        return self.status == self.TRIAL and self.trial_start_at <= now <= self.trial_end_at

    @property
    def days_remaining(self):
        now = timezone.now()
        if self.status == self.TRIAL and self.trial_end_at:
            return max((self.trial_end_at - now).days, 0)
        elif self.status == self.ACTIVE and self.end_date:
            return max((self.end_date - now).days, 0)
        return 0


    def start_trial(self):
        self.status = self.TRIAL
        self.payment_status = 'completed'
        trial_days = int(getattr(settings, 'TRIAL_PERIOD', 15))
        self.trial_start_at = timezone.now()
        self.trial_end_at = self.trial_start_at + timezone.timedelta(days=trial_days)
        self.start_date = self.trial_end_at
        self.end_date = self.start_date + timezone.timedelta(days=self.plan.period)
        self.next_due_date = self.end_date
        self.log_status_change(self.PENDING, self.TRIAL, reason='Started 15-day free trial')
        self.save()

    def activate_subscription(self):
        old_status = self.status
        self.status = self.ACTIVE
        self.payment_status = 'completed'
        self.start_date = timezone.now()
        self.end_date = self.start_date + timezone.timedelta(days=30 * self.plan.period)
        self.next_due_date = self.end_date
        self.last_payment_date = timezone.now()
        self.log_status_change(old_status, self.ACTIVE, reason='Trial ended or new payment made')
        self.save()

    def cancel_subscription(self, reason='Cancelled by user'):
        old_status = self.status
        self.status = self.CANCELLED
        self.is_active = False
        self.log_status_change(old_status, self.CANCELLED, reason=reason)
        self.save()

    def hold_subscription(self, reason='Autopay cancelled by user'):
        """Put subscription on hold when autopay is cancelled."""
        old_status = self.status
        self.status = self.HOLD
        self.is_active = False
        self.payment_status = 'pending'
        self.log_status_change(old_status, self.HOLD, reason=reason)
        self.save()

    def log_status_change(self, old_status, new_status, reason=None):
        OrganizationSubscriptionStatusHistory.objects.create(
            subscription=self,
            old_status=old_status,
            new_status=new_status,
            reason=reason or f'Status changed to {new_status}'
        )

    def __str__(self):
        return f"{self.user.username} - {self.plan.name} ({self.status})"



class OrganizationTransaction(models.Model):
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
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='subscription_orders',  null=True, blank=True)
    organization = models.ForeignKey(Organization, on_delete=models.CASCADE, related_name='subscription_org',  null=True, blank=True)
    trainer = models.ForeignKey('trainer.Trainer', on_delete=models.CASCADE, related_name='subscription_orders', null=True, blank=True)
    discipl_plan = models.ForeignKey(DisciplSubscriptionPlan, on_delete=models.PROTECT, null=True, blank=True)
    trainer_plan = models.ForeignKey('trainer.TrainerSubscriptionPlan', on_delete=models.PROTECT, null=True, blank=True)

    subscription = models.ForeignKey(OrganizationSubscriptionsDetails, on_delete=models.CASCADE, related_name='payments', null=True, blank=True)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    
    coupon = models.ForeignKey('user.Coupon', on_delete=models.SET_NULL, null=True, blank=True, related_name='organization_transactions')
    
    order_id = models.CharField(max_length=255, help_text="Razorpay Order ID", null=True, blank=True)
    payment_id = models.CharField(max_length=255, help_text="Razorpay Payment ID", null=True, blank=True)
    
    period = models.IntegerField(default=0)
    razorpay_signature = models.CharField(null=True, blank=True, max_length=1000)
    
    status = models.CharField(max_length=20, choices=PAYMENT_STATUS, default='PENDING')
    remarks = models.TextField(null=True, blank=True)

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
        return f"Payment {self.id} for {self.user.username}"
    


class OrganizationSubscriptionStatusHistory(models.Model):
    """Tracks every status change for a subscription"""

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    subscription = models.ForeignKey(OrganizationSubscriptionsDetails, on_delete=models.CASCADE, related_name='status_histories')
    old_status = models.CharField(max_length=20)
    new_status = models.CharField(max_length=20)
    changed_at = models.DateTimeField(auto_now_add=True)
    reason = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.subscription.user.username} status: {self.old_status} ➔ {self.new_status} at {self.changed_at}"


class PartnerTransfer(models.Model):
    """Model to track transfers made to partner accounts via Razorpay"""

    STATUS_CHOICES = [
        ('created', 'Created'),
        ('processed', 'Processed'),
        ('settled', 'Settled'),
        ('failed', 'Failed'),
    ]

    transfer_id = models.CharField(max_length=255, unique=True)
    account_id = models.CharField(max_length=255)  # Razorpay linked account
    amount = models.DecimalField(max_digits=10, decimal_places=2)

    order = models.ForeignKey(
        OrganizationTransaction,
        on_delete=models.SET_NULL,
        related_name="partner_transfers",
        null=True, blank=True
    )

    customer_transaction = models.ForeignKey(
        'customers.CustomerMembershipTransaction',
        on_delete=models.SET_NULL,
        related_name="partner_transfers",
        null=True, blank=True
    )

    status = models.CharField(
        max_length=50,
        choices=STATUS_CHOICES,
        default='created',
        help_text="Status of the transfer"
    )
    settlement_date = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    # New fields for enhanced tracking
    notes = models.TextField(null=True, blank=True, help_text="Transfer notes with customer and gym info")
    error_message = models.TextField(null=True, blank=True, help_text="Error details for failed attempts")
    retry_count = models.PositiveIntegerField(default=0, help_text="Number of retry attempts")
    last_retry_at = models.DateTimeField(null=True, blank=True, help_text="Timestamp of last retry")
    platform_fee = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True, help_text="Platform fee deducted (in rupees)")
    original_payment_amount = models.DecimalField(max_digits=10, decimal_places=2, null=True, blank=True, help_text="Original payment amount before split")

    class Meta:
        constraints = [
            # Allow multiple transfer attempts per transaction (for retries)
            # But only one successful transfer
            models.UniqueConstraint(
                fields=['customer_transaction', 'status'],
                name='uniq_successful_transfer_per_payment',
                condition=models.Q(
                    customer_transaction__isnull=False,
                    status='processed'  # Only one successful transfer
                )
            )
        ]

    def __str__(self):
        return f"Transfer {self.transfer_id} - {self.status}"
