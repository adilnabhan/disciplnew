from django.db import models
from django_extensions.db.fields import CreationDateTimeField
from apps.customers.models import Customer

class Badge(models.Model):
    name = models.CharField(max_length=100)
    description = models.TextField()
    icon_url = models.CharField(max_length=500, blank=True, null=True)
    xp_reward = models.PositiveIntegerField(default=50)
    coin_reward = models.PositiveIntegerField(default=10)
    created_at = CreationDateTimeField()

    def __str__(self):
        return self.name

class EarnedBadge(models.Model):
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, related_name='earned_badges')
    badge = models.ForeignKey(Badge, on_delete=models.CASCADE)
    earned_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('customer', 'badge')

    def __str__(self):
        return f"{self.customer} earned {self.badge.name}"

class CustomerPoints(models.Model):
    customer = models.OneToOneField(Customer, on_delete=models.CASCADE, related_name='points')
    xp = models.PositiveIntegerField(default=0)
    coins = models.PositiveIntegerField(default=0)
    streak_days = models.PositiveIntegerField(default=0)
    last_active_date = models.DateField(blank=True, null=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.customer} - XP: {self.xp}, Coins: {self.coins}, Streak: {self.streak_days}"
