from rest_framework import serializers
from .models import Account, EmailOTP
from django.contrib.auth.hashers import make_password, check_password
from django.utils import timezone
from datetime import timedelta

class SendOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()


class RegisterSerializer(serializers.ModelSerializer):
    otp = serializers.CharField(write_only=True)

    class Meta:
        model = Account
        fields = [
            'email',
            'username',
            'phone_number',
            'transaction_password',
            'password',
            'otp'
        ]
        extra_kwargs = {
            'password': {'write_only': True}
        }

    def validate(self, data):
        email = data.get('email')
        otp = str(data.get('otp')).strip()

        otp_obj = EmailOTP.objects.filter(email=email).order_by('-created_at').first()

        if not otp_obj:
            raise serializers.ValidationError("OTP tidak ditemukan")

        db_otp = str(otp_obj.otp).strip()

        print("INPUT OTP:", otp)
        print("DB OTP:", db_otp)

        if db_otp != otp:
            raise serializers.ValidationError("OTP salah")

        now = timezone.now()
        created = otp_obj.created_at

        print("NOW:", now)
        print("CREATED:", created)

        if now > created + timedelta(minutes=10):
            raise serializers.ValidationError("OTP sudah kadaluarsa")

        return data

    def create(self, validated_data):
        validated_data.pop('otp')

        validated_data['password'] = make_password(validated_data['password'])
        validated_data['transaction_password'] = make_password(validated_data['transaction_password'])

        user = Account.objects.create(**validated_data)

        EmailOTP.objects.filter(email=user.email).delete()

        return user

class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = '__all__'

class ChangePasswordSerializer(serializers.Serializer):
    user_id = serializers.IntegerField()
    old_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True)

    def validate(self, data):
        user = Account.objects.filter(id=data['user_id']).first()

        if not user:
            raise serializers.ValidationError("User tidak ditemukan")

        if not check_password(data['old_password'], user.password):
            raise serializers.ValidationError("Password lama salah")

        return data

    def save(self):
        user = Account.objects.get(id=self.validated_data['user_id'])
        user.password = make_password(self.validated_data['new_password'])
        user.save()
        return user
    
class ChangeTransactionPinSerializer(serializers.Serializer):
    user_id = serializers.IntegerField()
    old_pin = serializers.CharField(write_only=True)
    new_pin = serializers.CharField(write_only=True)

    def validate(self, data):
        user = Account.objects.filter(id=data['user_id']).first()

        if not user:
            raise serializers.ValidationError("User tidak ditemukan")

        if not user.transaction_password:
            raise serializers.ValidationError("PIN belum diset")

        if not check_password(data['old_pin'], user.transaction_password):
            raise serializers.ValidationError("PIN lama salah")

        return data

    def save(self):
        user = Account.objects.get(id=self.validated_data['user_id'])
        user.transaction_password = make_password(self.validated_data['new_pin'])
        user.save()
        return user
    
class VerifyOTPSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp = serializers.CharField()

    def validate(self, data):
        email = data.get('email')
        otp = str(data.get('otp')).strip()

        otp_obj = EmailOTP.objects.filter(email=email).order_by('-created_at').first()

        if not otp_obj:
            raise serializers.ValidationError("OTP tidak ditemukan")

        if str(otp_obj.otp).strip() != otp:
            raise serializers.ValidationError("OTP salah")

        if timezone.now() > otp_obj.created_at + timedelta(minutes=10):
            raise serializers.ValidationError("OTP sudah kadaluarsa")

        return data
    
class ResetPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()
    otp = serializers.CharField()
    new_password = serializers.CharField()

    def validate(self, data):
        email = data.get('email')
        otp = str(data.get('otp')).strip()

        otp_obj = EmailOTP.objects.filter(email=email).order_by('-created_at').first()

        if not otp_obj:
            raise serializers.ValidationError("OTP tidak ditemukan")

        if str(otp_obj.otp).strip() != otp:
            raise serializers.ValidationError("OTP salah")

        if timezone.now() > otp_obj.created_at + timedelta(minutes=10):
            raise serializers.ValidationError("OTP sudah kadaluarsa")

        return data

    def save(self):
        email = self.validated_data['email']
        new_password = self.validated_data['new_password']

        user = Account.objects.filter(email=email).first()

        if not user:
            raise serializers.ValidationError("User tidak ditemukan")

        user.password = make_password(new_password)
        user.save()

        EmailOTP.objects.filter(email=email).delete()

        return user