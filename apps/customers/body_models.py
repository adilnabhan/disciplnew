from django.db import models
from django_extensions.db.fields import CreationDateTimeField
from apps.customers.models import Customer
from datetime import date

class WeightLog(models.Model):
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, related_name='weight_logs')
    weight_kg = models.DecimalField(max_digits=5, decimal_places=2)
    logged_at = models.DateField(default=date.today)
    created_at = CreationDateTimeField()

    def __str__(self):
        return f"{self.customer} - {self.weight_kg}kg on {self.logged_at}"

class BodyMeasurementLog(models.Model):
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, related_name='measurement_logs')
    neck_cm = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    chest_cm = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    biceps_cm = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    waist_cm = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    hips_cm = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    thighs_cm = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    logged_at = models.DateField(default=date.today)
    created_at = CreationDateTimeField()

    def __str__(self):
        return f"{self.customer} - measurements on {self.logged_at}"

class ProgressPhoto(models.Model):
    PHOTO_TYPE_CHOICES = (
        ('front', 'Front'),
        ('side', 'Side'),
        ('back', 'Back'),
    )
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, related_name='progress_photos')
    photo = models.ImageField(upload_to='progress_photos/')
    photo_type = models.CharField(max_length=10, choices=PHOTO_TYPE_CHOICES)
    logged_at = models.DateField(default=date.today)
    created_at = CreationDateTimeField()

    def __str__(self):
        return f"{self.customer} - {self.photo_type} photo on {self.logged_at}"
