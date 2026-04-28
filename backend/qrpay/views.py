from rest_framework.views import APIView
from rest_framework.response import Response
from django.contrib.auth import get_user_model
from django.shortcuts import get_object_or_404
from rest_framework import status
from django.utils import timezone
from .models import Qris
from .serializers import QrisSerializer, QrisScanSerializer

User = get_user_model()
DEMO_QRIS_NUMBER = '011006081106'


class GenerateQRView(APIView):
    def get(self, request):
        return Response({
            "qr_data": str(request.user.id)
        })


class ResolveQRView(APIView):
    def get(self, request, user_id):
        user = get_object_or_404(User, id=user_id)

        return Response({
            "user_id": user.id,
            "username": user.username,
            "phone_number": user.phone_number,
        })

class QrisListCreateView(APIView):
    def get(self, request):
        qris_records = Qris.objects.all().order_by('-transaction_date', '-transaction_time')
        return Response(QrisSerializer(qris_records, many=True).data)

    def post(self, request):
        serializer = QrisSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class QrisDetailView(APIView):
    def get(self, request, qris_id):
        qris = get_object_or_404(Qris, id=qris_id)
        return Response(QrisSerializer(qris).data)


class QrisScanView(APIView):
    def post(self, request):
        scan_serializer = QrisScanSerializer(data=request.data)
        if not scan_serializer.is_valid():
            return Response(scan_serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        # 1 fix qris_number untuk kita demo aja mingdep
        qris = Qris.objects.filter(qris_number=DEMO_QRIS_NUMBER).first()

        if not qris:
            return Response(
                {'error': f'QRIS demo {DEMO_QRIS_NUMBER} belum ada di admin'},
                status=status.HTTP_404_NOT_FOUND,
            )

        qris_data = QrisSerializer(qris).data
        scanned_at = timezone.localtime(timezone.now())

        response_data = {
            **qris_data,
            'transaction_id': str(qris.id),
            'method_type': 'qris',
            'method_label': 'Pembayaran Qris',
            'payment_method_label': 'Pembayaran Qris',
            'transaction_fee': 0,
            'remaining_balance': 0,
            'success_title': 'Payment Successful!',
            'success_method_label': 'Pembayaran Qris',
            'merchant': {
                'name': qris.merchant_name,
                'account_name': qris.merchant_PT,
                'transacted_at': scanned_at.isoformat(),
                'transaction_date': scanned_at.date().isoformat(),
                'transaction_time': scanned_at.time().strftime('%H:%M:%S'),
                'logo_text': qris.merchant_name[:1].upper() if qris.merchant_name else 'M',
            },
        }

        return Response(response_data)