from django.db import models
from django_extensions.db.fields import CreationDateTimeField
from apps.customers.models import Customer
from datetime import date

class Food(models.Model):
    name = models.CharField(max_length=255)
    calories = models.PositiveIntegerField(help_text="Calories per serving")
    protein = models.DecimalField(max_digits=5, decimal_places=2, default=0.0)
    carbs = models.DecimalField(max_digits=5, decimal_places=2, default=0.0)
    fat = models.DecimalField(max_digits=5, decimal_places=2, default=0.0)
    fiber = models.DecimalField(max_digits=5, decimal_places=2, default=0.0)
    serving_size = models.CharField(max_length=100, default="100g")
    is_global = models.BooleanField(default=True)
    created_at = CreationDateTimeField()

    def __str__(self):
        return self.name

class FoodLog(models.Model):
    MEAL_CHOICES = (
        ('breakfast', 'Breakfast'),
        ('lunch', 'Lunch'),
        ('dinner', 'Dinner'),
        ('snack', 'Snacks'),
    )
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, related_name='food_logs')
    food = models.ForeignKey(Food, on_delete=models.CASCADE)
    meal_type = models.CharField(max_length=20, choices=MEAL_CHOICES)
    servings = models.DecimalField(max_digits=4, decimal_places=2, default=1.0)
    logged_at = models.DateField(default=date.today)
    created_at = CreationDateTimeField()

    def __str__(self):
        return f"{self.customer} - {self.food.name} ({self.meal_type})"

class WaterLog(models.Model):
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, related_name='water_logs')
    amount_ml = models.PositiveIntegerField(help_text="Amount in ml")
    logged_at = models.DateField(default=date.today)
    created_at = CreationDateTimeField()

    def __str__(self):
        return f"{self.customer} - {self.amount_ml}ml on {self.logged_at}"
