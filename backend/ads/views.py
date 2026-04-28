from rest_framework.generics import ListCreateAPIView
from django.utils import timezone
from .models import Ad
from .serializers import AdSerializer

class AdListCreateView(ListCreateAPIView):
    serializer_class = AdSerializer

    def get_queryset(self):
        now = timezone.now()
        return Ad.objects.filter(start_date__lte=now, end_date__gte=now)