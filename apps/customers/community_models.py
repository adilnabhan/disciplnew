from django.db import models
from django_extensions.db.fields import CreationDateTimeField
from apps.customers.models import Customer

class CommunityPost(models.Model):
    POST_TYPE_CHOICES = (
        ('custom', 'Custom Post'),
        ('workout_completed', 'Workout Completed'),
        ('pr_achieved', 'Personal Record Achieved'),
        ('streak_milestone', 'Streak Milestone'),
    )
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE, related_name='posts')
    post_type = models.CharField(max_length=25, choices=POST_TYPE_CHOICES, default='custom')
    caption = models.TextField(blank=True, null=True)
    media_url = models.CharField(max_length=500, blank=True, null=True)
    created_at = CreationDateTimeField()

    def __str__(self):
        return f"{self.customer.user.username if self.customer.user else 'Unknown'} - {self.post_type}"

class CommunityLike(models.Model):
    post = models.ForeignKey(CommunityPost, on_delete=models.CASCADE, related_name='likes')
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('post', 'customer')

    def __str__(self):
        return f"{self.customer} liked post {self.post.id}"

class CommunityComment(models.Model):
    post = models.ForeignKey(CommunityPost, on_delete=models.CASCADE, related_name='comments')
    customer = models.ForeignKey(Customer, on_delete=models.CASCADE)
    comment_text = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.customer} commented on post {self.post.id}"
