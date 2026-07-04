from django.conf import settings

from django.db import models

from apps.fitnesscenter.models import Organization

# Create your models here.

class MentorProfile(models.Model):
    ADMIN = 'admin'
    ACCOUNTS = 'accounts'
    TRAINER = 'trainer'

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        null=True, blank=True,
        related_name='mentor_profile',
    )
    organization = models.ForeignKey(
        Organization,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='mentors',
        help_text="Organization the mentor belongs to"
    )
    designation = models.CharField(max_length=10, choices=[
        ('admin', ADMIN),
        ('accounts', ACCOUNTS),
        ('trainer', TRAINER),
    ], default=ADMIN) 
    hash_of_user_phone_number = models.CharField(max_length=128, null=True, blank=True)
    experience = models.CharField(max_length=50, blank=True, null=True, help_text="Years of experience")
    emergency_contact = models.CharField(max_length=15, blank=True, null=True, help_text="Emergency contact number")
    address_proof = models.FileField(upload_to='documents/address_proofs/', blank=True, null=True, help_text="Upload address proof")
    categories = models.ManyToManyField('fitnesscenter.Category', related_name='mentors', blank=True, help_text="Categories the mentor belongs to")


    # is_active => should be used from user.is_active.

    @property
    def is_active(self):
        # is active if user profile is detached or if user profile is inactive
        return getattr(self.user, 'is_active', False)
    
    @property
    def full_name(self):
        if self.user:
            return f"{self.user.first_name} {self.user.last_name}"
        return "Unknown"
    
    
class TrainerCertificate(models.Model):
    mentor_profile = models.ForeignKey(
        MentorProfile,
        on_delete=models.CASCADE,
        related_name='trainer_certificates',
        help_text="Mentor profile associated with this fitness certificate"
    )
    certificate = models.FileField(
        upload_to='documents/trainer_certificates/',
        blank=True,
        null=True,
        help_text="Upload fitness certificate"
    )
    uploaded_at = models.DateTimeField(auto_now_add=True, help_text="Date and time when the certificate was uploaded")

    def __str__(self):
        return f"Fitness Certificate for {self.mentor_profile.full_name} (Uploaded: {self.uploaded_at.strftime('%Y-%m-%d')})"

    class Meta:
        verbose_name = "Fitness Certificate"
        verbose_name_plural = "Fitness Certificates"
