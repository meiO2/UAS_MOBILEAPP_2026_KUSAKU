from django.contrib import admin
from .models import Qris
# Register your models here.
@admin.register(Qris)
class QrisAdmin(admin.ModelAdmin):
    list_display = ('qris_number', 'merchant_name', 
                    'merchant_PT', 'amount', 'transaction_date', 'transaction_time')
    
