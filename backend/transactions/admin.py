from django.contrib import admin
from .models import Category, Expense, Income, CategoryBudget

admin.site.register(Category)
admin.site.register(Expense)
admin.site.register(Income)
admin.site.register(CategoryBudget)