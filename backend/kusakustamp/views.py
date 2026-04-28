from rest_framework.views import APIView
from rest_framework.response import Response
from django.utils import timezone
from .models import Stamp, UserStamp
from .serializers import StampSerializer, UserStampSerializer
from transactions.models import Expense
from django.db.models import Sum
from rest_framework.permissions import IsAdminUser
from rest_framework import generics
from rest_framework.parsers import MultiPartParser, FormParser


class StampListView(APIView):

    def get(self, request):
        stamps = Stamp.objects.filter(deadline__gt=timezone.now())
        return Response(StampSerializer(stamps, many=True).data)


class RedeemStampView(APIView):

    def post(self, request, stamp_id, user_id):
        try:
            stamp = Stamp.objects.get(id=stamp_id)
        except Stamp.DoesNotExist:
            return Response({"error": "Stamp tidak ditemukan."}, status=404)

        if stamp.is_expired():
            return Response({"error": "Stamp sudah kadaluarsa."}, status=400)

        points_earned = Expense.objects.filter(user_id=user_id).aggregate(
            total=Sum('kusaku_points')
        )['total'] or 0

        points_spent = UserStamp.objects.filter(user_id=user_id).aggregate(
            total=Sum('points_used')
        )['total'] or 0

        kusaku_points = points_earned - points_spent

        if kusaku_points < stamp.points_needed:
            return Response({
                "error": "Poin tidak cukup.",
                "current_points": kusaku_points,
                "points_needed": stamp.points_needed,
            }, status=400)

        user_stamp = UserStamp.objects.create(
            user_id=user_id,
            stamp=stamp,
            points_used=stamp.points_needed,
        )

        return Response({
            "message": "Stamp berhasil ditukarkan!",
            "redeemed": UserStampSerializer(user_stamp).data,
            "remaining_points": kusaku_points - stamp.points_needed,
        }, status=201)


class UserStampHistoryView(APIView):

    def get(self, request, user_id):
        user_stamps = UserStamp.objects.filter(user_id=user_id)
        return Response(UserStampSerializer(user_stamps, many=True).data)


class StampCreateView(generics.CreateAPIView):
    permission_classes = [IsAdminUser]
    parser_classes = [MultiPartParser, FormParser]
    queryset = Stamp.objects.all()
    serializer_class = StampSerializer