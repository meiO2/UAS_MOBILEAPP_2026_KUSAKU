from django.db.models.signals import post_save
from django.dispatch import receiver
from django.conf import settings

from transactions.models import Category, CategoryBudget

User = settings.AUTH_USER_MODEL


DEFAULT_CATEGORIES = [
    "Kebutuhan Rumah",
    "Makan & Minum",
    "Transportasi",
    "Investasi",
    "Tabungan",
    "Hiburan",
    "Tagihan",
    "Kesehatan",
    "Pendidikan",
]


@receiver(post_save, sender=User)
def create_user_defaults(sender, instance, created, **kwargs):
    if created:
        if Category.objects.filter(user=instance).exists():
            return

        for name in DEFAULT_CATEGORIES:
            category = Category.objects.create(
                user=instance,
                name=name
            )

            CategoryBudget.objects.create(
                user=instance,
                category=category,
                percentage=0
            )