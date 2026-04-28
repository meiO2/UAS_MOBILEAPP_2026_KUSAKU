from django.urls import path
from .views import StampListView, RedeemStampView, UserStampHistoryView, StampCreateView

urlpatterns = [
    path('view/', StampListView.as_view()),
    path('redeem/<int:stamp_id>/<int:user_id>/', RedeemStampView.as_view()),
    path('history/<int:user_id>/', UserStampHistoryView.as_view()),
    path('create/', StampCreateView.as_view()),
]