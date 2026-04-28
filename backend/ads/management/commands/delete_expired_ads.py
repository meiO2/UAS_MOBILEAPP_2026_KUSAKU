from django.core.management.base import BaseCommand
from django.utils import timezone
from ads.models import Ad

class Command(BaseCommand):
    help = 'Delete expired ads'

    def handle(self, *args, **kwargs):
        now = timezone.now()
        expired_ads = Ad.objects.filter(end_date__lt=now)
        count = expired_ads.count()
        expired_ads.delete()

        self.stdout.write(f"{count} expired ads deleted")