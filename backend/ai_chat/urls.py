from django.urls import path
from .views import ChatSessionView, ChatMessageView, InitBudgetView

urlpatterns = [
    path('session/<int:user_id>/', ChatSessionView.as_view()),
    path('message/<int:user_id>/', ChatMessageView.as_view()),
    path('init-budget/<int:user_id>/', InitBudgetView.as_view()),  # ← new
]