from rest_framework import serializers

from .models import Qris


class QrisSerializer(serializers.ModelSerializer):
    def validate_qris_number(self, value):
        if not value.isdigit() or len(value) != 12:
            raise serializers.ValidationError('qris_number harus 12 digit angka, contoh: 011006081106')
        return value

    class Meta:
        model = Qris
        fields = [
            'id',
            'qris_number',
            'merchant_name',
            'merchant_PT',
            'transaction_date',
            'transaction_time',
            'amount',
        ]
        read_only_fields = ['id', 'transaction_date', 'transaction_time']


class QrisScanSerializer(serializers.Serializer):
    qris_number = serializers.CharField(max_length=512, trim_whitespace=True)
