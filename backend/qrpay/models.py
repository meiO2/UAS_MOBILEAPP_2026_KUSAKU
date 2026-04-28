from django.db import models

class Qris(models.Model):
        qris_number = models.CharField(max_length=255, unique=True)
        merchant_name = models.CharField(max_length=255)
        merchant_PT = models.CharField(max_length=255)
        transaction_date = models.DateTimeField(auto_now_add=True)
        transaction_time = models.TimeField(auto_now_add=True)
        amount = models.DecimalField(max_digits=10, decimal_places=2)

        def __str__(self):
            return f"Qris {self.qris_number} - {self.merchant_name}"
        
        