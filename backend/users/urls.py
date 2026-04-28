from django.urls import path
from .views import SendOTPView, RegisterView, LoginView, ProfileDetailView, ChangePasswordView, ChangeTransactionPinView, VerifyOTPView, ResetPasswordView, SendForgotPasswordOTPView, UpdateProfileView, VerifyTransactionPinView

urlpatterns = [
    path('send-otp/', SendOTPView.as_view(), name='send-otp'),
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('profile/<int:user_id>/', ProfileDetailView.as_view(), name='profile-detail'),
    path('change-password/', ChangePasswordView.as_view(), name='change-password'),
    path('change-pin/', ChangeTransactionPinView.as_view(), name='change-pin'),
    path('verify-otp/', VerifyOTPView.as_view(), name='verify-otp'),
    path('reset-password/', ResetPasswordView.as_view(), name='reset-password'),
    path('forgot-password/send-otp/', SendForgotPasswordOTPView.as_view()),
    path('profile/update/<int:user_id>/', UpdateProfileView.as_view()),
    path('verify-pin/', VerifyTransactionPinView.as_view(), name='verify-pin'),
]