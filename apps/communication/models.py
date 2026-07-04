from django.db import models
from django.conf import settings


class DeviceToken(models.Model):
    """Stores FCM device tokens for push notifications."""

    PLATFORM_CHOICES = [
        ('mentor-app-ios', 'Mentor App iOS'),
        ('mentor-app-android', 'Mentor App Android'),
        ('customer-app-ios', 'Customer App iOS'),
        ('customer-app-android', 'Customer App Android'),
    ]

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='device_tokens'
    )
    token = models.CharField(max_length=500, unique=True)
    platform = models.CharField(max_length=30, choices=PLATFORM_CHOICES)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('user', 'token')

    def __str__(self):
        return f"{self.user.full_name} - {self.platform} ({self.token[:20]}...)"


# ============================================================
# WhatsApp Automation & Message Credit System
# ============================================================

class MessageCreditWallet(models.Model):
    """Per-organization message credit wallet."""
    organization = models.OneToOneField(
        'fitnesscenter.Organization',
        on_delete=models.CASCADE,
        related_name='credit_wallet'
    )
    available_credits = models.IntegerField(default=0)
    used_credits = models.IntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    @property
    def total_purchased(self):
        return self.available_credits + self.used_credits

    def has_credits(self, count=1):
        return self.available_credits >= count

    def deduct(self, count=1):
        if not self.has_credits(count):
            raise ValueError("Insufficient credits")
        self.available_credits -= count
        self.used_credits += count
        self.save(update_fields=['available_credits', 'used_credits', 'updated_at'])

    def refund(self, count=1):
        self.available_credits += count
        self.used_credits -= count
        self.save(update_fields=['available_credits', 'used_credits', 'updated_at'])

    def add_credits(self, count):
        self.available_credits += count
        self.save(update_fields=['available_credits', 'updated_at'])

    def __str__(self):
        return f"{self.organization.name} — {self.available_credits} credits"


class MessageCreditTransaction(models.Model):
    """Tracks every credit movement (purchase, deduction, refund)."""
    TYPE_CHOICES = [
        ('purchase', 'Purchase'),
        ('deduction', 'Deduction'),
        ('refund', 'Refund'),
    ]

    organization = models.ForeignKey(
        'fitnesscenter.Organization',
        on_delete=models.CASCADE,
        related_name='credit_transactions'
    )
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    credits = models.IntegerField()
    amount = models.DecimalField(
        max_digits=10, decimal_places=2,
        null=True, blank=True,
        help_text="Payment amount for purchases"
    )
    reference_type = models.CharField(
        max_length=50, blank=True, default='',
        help_text="campaign, automation, manual, purchase"
    )
    reference_id = models.BigIntegerField(
        null=True, blank=True,
        help_text="ID of the related object"
    )
    payment_id = models.CharField(
        max_length=200, blank=True, default='',
        help_text="Razorpay payment ID for purchases"
    )
    notes = models.TextField(blank=True, default='')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.organization.name} — {self.type} {self.credits} credits"


class WhatsAppTemplate(models.Model):
    """WhatsApp message templates with dynamic placeholders."""
    EVENT_CHOICES = [
        ('birthday', 'Birthday Greeting'),
        ('expiry_reminder', 'Membership Expiry Reminder'),
        ('renewal_reminder', 'Renewal Reminder'),
        ('festival', 'Festival Greeting'),
        ('welcome', 'Welcome Message'),
        ('payment_confirmation', 'Payment Confirmation'),
        ('custom', 'Custom'),
    ]
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('inactive', 'Inactive'),
        ('pending_approval', 'Pending Approval'),
    ]

    organization = models.ForeignKey(
        'fitnesscenter.Organization',
        on_delete=models.CASCADE,
        related_name='whatsapp_templates'
    )
    name = models.CharField(max_length=200)
    event_type = models.CharField(max_length=30, choices=EVENT_CHOICES)
    meta_template_id = models.CharField(
        max_length=200, blank=True, default='',
        help_text="Template ID from Meta WhatsApp Business API"
    )
    content = models.TextField(
        help_text="Message body with {{member_name}}, {{gym_name}}, {{expiry_date}}, {{renewal_amount}} placeholders"
    )
    variables = models.JSONField(
        default=list, blank=True,
        help_text="List of supported placeholder names"
    )
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='active')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.name} ({self.event_type})"

    def render(self, context: dict) -> str:
        """Render template with context variables."""
        rendered = self.content
        for key, value in context.items():
            rendered = rendered.replace(f"{{{{{key}}}}}", str(value))
        return rendered


class AutomationRule(models.Model):
    """Configurable automation triggers per organization."""
    EVENT_CHOICES = [
        ('birthday', 'Birthday'),
        ('expiry_reminder', 'Membership Expiry Reminder'),
        ('renewal_reminder', 'Renewal Reminder'),
        ('onam', 'Onam'),
        ('vishu', 'Vishu'),
        ('christmas', 'Christmas'),
        ('eid', 'Eid'),
        ('new_year', 'New Year'),
    ]

    organization = models.ForeignKey(
        'fitnesscenter.Organization',
        on_delete=models.CASCADE,
        related_name='automation_rules'
    )
    event_type = models.CharField(max_length=30, choices=EVENT_CHOICES)
    template = models.ForeignKey(
        WhatsAppTemplate,
        on_delete=models.CASCADE,
        related_name='automation_rules'
    )
    trigger_days_before = models.IntegerField(
        default=0,
        help_text="Days before the event to trigger (0 = on the day)"
    )
    send_time = models.TimeField(
        default='09:00',
        help_text="Time of day to send (IST)"
    )
    enabled = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('organization', 'event_type')
        ordering = ['-created_at']

    def __str__(self):
        status = "✅" if self.enabled else "❌"
        return f"{status} {self.organization.name} — {self.event_type}"


class MessageQueue(models.Model):
    """Queue of messages to be sent."""
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('processing', 'Processing'),
        ('sent', 'Sent'),
        ('failed', 'Failed'),
        ('cancelled', 'Cancelled'),
    ]

    organization = models.ForeignKey(
        'fitnesscenter.Organization',
        on_delete=models.CASCADE,
        related_name='message_queue'
    )
    member = models.ForeignKey(
        'customers.Customer',
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='queued_messages'
    )
    phone = models.CharField(max_length=20)
    template = models.ForeignKey(
        WhatsAppTemplate,
        on_delete=models.SET_NULL,
        null=True, blank=True,
        related_name='queued_messages'
    )
    rendered_message = models.TextField(
        blank=True, default='',
        help_text="Final rendered message text"
    )
    payload = models.JSONField(
        default=dict, blank=True,
        help_text="Template variables used for rendering"
    )
    scheduled_at = models.DateTimeField(
        help_text="When to send this message"
    )
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    retry_count = models.IntegerField(default=0)
    max_retries = models.IntegerField(default=3)
    error_message = models.TextField(blank=True, default='')
    source = models.CharField(
        max_length=30, default='automation',
        help_text="automation, campaign, manual"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['scheduled_at']

    def __str__(self):
        return f"→ {self.phone} ({self.status}) [{self.source}]"


class MessageLog(models.Model):
    """Tracks delivery status from WhatsApp API."""
    STATUS_CHOICES = [
        ('sent', 'Sent'),
        ('delivered', 'Delivered'),
        ('read', 'Read'),
        ('failed', 'Failed'),
    ]

    queue_entry = models.OneToOneField(
        MessageQueue,
        on_delete=models.CASCADE,
        related_name='log'
    )
    whatsapp_message_id = models.CharField(
        max_length=200, blank=True, default='',
        help_text="Message ID from Meta API response"
    )
    response = models.JSONField(
        default=dict, blank=True,
        help_text="Full API response"
    )
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='sent')
    sent_at = models.DateTimeField(null=True, blank=True)
    delivered_at = models.DateTimeField(null=True, blank=True)
    read_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Log #{self.id} — {self.status} ({self.queue_entry.phone})"

