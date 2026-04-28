from django.db import models
from django.contrib.auth import get_user_model
from django.utils import timezone

User = get_user_model()

class Stamp(models.Model):
    image        = models.ImageField(upload_to='stamps/')
    title        = models.CharField(max_length=255)
    points_needed = models.PositiveIntegerField()
    deadline     = models.DateTimeField()
    reward_label = models.CharField(max_length=255)

    def is_expired(self):
        return timezone.now() > self.deadline

    def __str__(self):
        return self.title


class UserStamp(models.Model):
    user         = models.ForeignKey(User, on_delete=models.CASCADE, related_name='stamps')
    stamp        = models.ForeignKey(Stamp, on_delete=models.PROTECT, related_name='redemptions')
    points_used  = models.PositiveIntegerField() 
    redeemed_at  = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-redeemed_at']

    def __str__(self):
        return f"{self.user} → {self.stamp.title}"