from rest_framework import serializers
from .models import Stamp, UserStamp
from django.utils import timezone

class StampSerializer(serializers.ModelSerializer):
    is_expired = serializers.SerializerMethodField()

    class Meta:
        model = Stamp
        fields = ['id', 'image', 'title', 'points_needed', 'deadline', 'reward_label', 'is_expired']

    def get_is_expired(self, obj):
        return obj.is_expired()


class UserStampSerializer(serializers.ModelSerializer):
    stamp = StampSerializer(read_only=True)
    
    class Meta:
        model = UserStamp
        fields = '__all__'