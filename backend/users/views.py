import random
from django.core.mail import send_mail
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.conf import settings
from django.contrib.auth import authenticate
from django.shortcuts import get_object_or_404
from django.contrib.auth import authenticate
from rest_framework.permissions import AllowAny
from django.contrib.auth.hashers import check_password  # add this

from .models import EmailOTP, Account
from .serializers import RegisterSerializer, SendOTPSerializer, ChangePasswordSerializer, ChangeTransactionPinSerializer, VerifyOTPSerializer, ResetPasswordSerializer

class SendOTPView(APIView):
    def post(self, request):
        serializer = SendOTPSerializer(data=request.data)

        if serializer.is_valid():
            email = serializer.validated_data['email']

            if Account.objects.filter(email=email).exists():
                return Response(
                    {"error": "Email sudah terdaftar"},
                    status=status.HTTP_400_BAD_REQUEST
                )

            otp = str(random.randint(100000, 999999))

            EmailOTP.objects.filter(email=email).delete()

            EmailOTP.objects.create(
                email=email,
                otp=otp
            )

            print("SENT OTP:", otp)

            send_mail(
                'Kode OTP Kusaku',
                (f'Kode OTP kamu adalah {otp}'),
                settings.EMAIL_HOST_USER,
                [email],
                fail_silently=False,
            )

            return Response({"message": "OTP dikirim"}, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class RegisterView(APIView):
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)

        if serializer.is_valid():
            serializer.save()
            return Response({"message": "Akun berhasil dibuat"}, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    permission_classes = [AllowAny]
    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')

        user = authenticate(username=username, password=password)

        if user is not None:
            return Response({"user_id": user.id, "username": user.username}, status=status.HTTP_200_OK)
        
        return Response({"error": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)

class ProfileDetailView(APIView):
    def get(self, request, user_id):
        user = get_object_or_404(Account, id=user_id)

        serializer = RegisterSerializer(user) 
        return Response(serializer.data, status=status.HTTP_200_OK)

class ChangePasswordView(APIView):
    def post(self, request):
        serializer = ChangePasswordSerializer(data=request.data)

        if serializer.is_valid():
            serializer.save()
            return Response({"message": "Password berhasil diubah"}, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class ChangeTransactionPinView(APIView):
    def post(self, request):
        serializer = ChangeTransactionPinSerializer(data=request.data)

        if serializer.is_valid():
            serializer.save()
            return Response({"message": "PIN berhasil diubah"}, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class VerifyOTPView(APIView):
    def post(self, request):
        serializer = VerifyOTPSerializer(data=request.data)

        if serializer.is_valid():
            return Response({"message": "OTP valid"}, status=200)

        return Response(serializer.errors, status=400)
    
class ResetPasswordView(APIView):
    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)

        if serializer.is_valid():
            serializer.save()
            return Response({"message": "Password berhasil direset"}, status=200)

        return Response(serializer.errors, status=400)
    
class SendForgotPasswordOTPView(APIView):
    def post(self, request):
        serializer = SendOTPSerializer(data=request.data)

        if serializer.is_valid():
            email = serializer.validated_data['email']

            if not Account.objects.filter(email=email).exists():
                return Response(
                    {"error": "Email tidak terdaftar"},
                    status=status.HTTP_400_BAD_REQUEST
                )

            otp = str(random.randint(100000, 999999))

            EmailOTP.objects.filter(email=email).delete()

            EmailOTP.objects.create(
                email=email,
                otp=otp
            )

            print("RESET OTP:", otp)

            send_mail(
                'Reset Password OTP',
                f'Kode OTP kamu adalah {otp}',
                settings.EMAIL_HOST_USER,
                [email],
                fail_silently=False,
            )

            return Response(
                {"message": "OTP dikirim untuk reset password"},
                status=status.HTTP_200_OK
            )

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UpdateProfileView(APIView):
    def put(self, request, user_id):
        user = get_object_or_404(Account, id=user_id)

        user.username = request.data.get('username', user.username)
        user.email = request.data.get('email', user.email)
        user.phone_number = request.data.get('phone_number', user.phone_number)

        user.save()

        return Response({
            "message": "Profile updated successfully",
            "username": user.username,
            "email": user.email,
            "phone_number": user.phone_number,
        }, status=200)

class VerifyTransactionPinView(APIView):
    def post(self, request):
        user_id = request.data.get('user_id')
        pin = request.data.get('pin')

        user = Account.objects.filter(id=user_id).first()
        if not user:
            return Response({"error": "User tidak ditemukan"}, status=404)

        if not user.transaction_password:
            return Response({"error": "PIN belum diset"}, status=400)

        if not check_password(pin, user.transaction_password):
            return Response({"error": "PIN salah"}, status=400)

        return Response({"message": "PIN valid"}, status=200)
