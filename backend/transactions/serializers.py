from rest_framework import serializers
from .models import Category, Expense, Income, CategoryBudget, Transfer


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'is_active']


class CategoryBudgetSerializer(serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)

    remaining_amount = serializers.SerializerMethodField()

    class Meta:
        model = CategoryBudget
        fields = [
            'id',
            'category',
            'percentage',
            'allocated_amount',
            'used_amount',
            'remaining_amount'
        ]

    def get_remaining_amount(self, obj):
        return obj.allocated_amount - obj.used_amount


class ExpenseSerializer(serializers.ModelSerializer):
    category_name = serializers.CharField(source='category.name', read_only=True)
    category_icon = serializers.CharField(source='category.icon', read_only=True)

    class Meta:
        model = Expense
        fields = '__all__'
        read_only_fields = ['user', 'kusaku_points']


class IncomeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Income
        fields = '__all__'
        read_only_fields = ['user']

class TransferSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transfer
        fields = '__all__'
        read_only_fields = ['sender', 'recipient', 'date']