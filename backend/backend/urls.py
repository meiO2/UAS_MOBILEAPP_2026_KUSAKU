from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    path('admin/', admin.site.urls), 
    
    path('api/users/', include('users.urls')),
    path('api/ads/', include('ads.urls')),
    path('api/', include('transactions.urls')),
    path('api/stamp/', include('kusakustamp.urls')),
    path('api/qr/', include('qrpay.urls')),
    path('api/ai/', include('ai_chat.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

