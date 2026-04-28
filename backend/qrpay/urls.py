from django.urls import path
from .views import GenerateQRView, ResolveQRView
from .views import QrisListCreateView, QrisDetailView, QrisScanView

urlpatterns = [
    path('generate/', GenerateQRView.as_view()),
    path('resolve/<int:user_id>/', ResolveQRView.as_view()),
    path('', QrisListCreateView.as_view()),
    path('scan/', QrisScanView.as_view()),
    path('<int:qris_id>/', QrisDetailView.as_view()),
]