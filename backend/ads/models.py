from django.db import models
from django.utils import timezone

class Ad(models.Model):
    image = models.ImageField(upload_to='ads/')
    start_date = models.DateTimeField()
    end_date = models.DateTimeField()

    def is_active(self):
        now = timezone.now()
        return self.start_date <= now <= self.end_date

    def __str__(self):
        return f"Ad {self.id}"