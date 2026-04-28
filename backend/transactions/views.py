from rest_framework.views import APIView
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from rest_framework import status
from django.db.models import Sum
from django.db import transaction

from .models import Category, Expense, Income, CategoryBudget, Transfer
from .serializers import (
    CategorySerializer,
    ExpenseSerializer,
    IncomeSerializer,
    CategoryBudgetSerializer,
)
from kusakustamp.models import UserStamp
from users.models import Account


class CategoryListView(APIView):

    def get(self, request):
        categories = Category.objects.filter(user=request.user)
        return Response(CategorySerializer(categories, many=True).data)


class CategoryUpdateView(APIView):
    """
    Called by ChatSiPintar when the user sets/updates their budget.
    This is the ONLY place that writes allocated_amount.
    It calculates from current total_income and saves it permanently.
    """

    def post(self, request, pk):
        print("REQUEST DATA:", request.data)

        user = get_object_or_404(Account, pk=pk)
        categories = request.data.get("categories", [])

        total_income = Income.objects.filter(user=user).aggregate(
            total=Sum('amount')
        )['total'] or 0

        updated = []

        for cat_data in categories:
            cat_id = cat_data.get("id")
            category = get_object_or_404(Category, pk=cat_id, user=user)

            category.is_active = cat_data.get("enabled", category.is_active)
            category.save()

            budget, _ = CategoryBudget.objects.get_or_create(
                user=user,
                category=category
            )

            percentage = cat_data.get("percentage", budget.percentage)
            budget.percentage = percentage
            budget.allocated_amount = (percentage / 100) * float(total_income)
            budget.save()

            updated.append({
                "id": category.id,
                "name": category.name,
                "percentage": budget.percentage,
                "enabled": category.is_active,
            })

        return Response(updated)


class BudgetView(APIView):

    def get(self, request, user_id):
        budgets = CategoryBudget.objects.filter(
            user_id=user_id,
            category__is_active=True,
            percentage__gt=0
        ).select_related('category')

        result = []
        for budget in budgets:
            allocated = float(budget.allocated_amount)
            used = float(budget.used_amount)
            remaining = max(allocated - used, 0)

            result.append({
                "category": {
                    "id": budget.category.id,
                    "name": budget.category.name,
                },
                "percentage": budget.percentage,
                "allocated_amount": allocated,
                "used_amount": used,
                "remaining_amount": remaining,
            })

        return Response(result)

    def put(self, request, user_id):
        """
        Manual bulk update of budget percentages.
        Also recalculates and saves allocated_amount based on current income.
        """
        data = request.data

        if not isinstance(data, list):
            return Response(
                {"error": "Invalid data format, expected a list"},
                status=status.HTTP_400_BAD_REQUEST
            )

        total = sum(item.get('percentage', 0) for item in data)
        if total > 100 or total < 0:
            return Response(
                {"error": "Total percentage must be between 0 and 100"},
                status=status.HTTP_400_BAD_REQUEST
            )

        total_income = Income.objects.filter(user_id=user_id).aggregate(
            total=Sum('amount')
        )['total'] or 0

        with transaction.atomic():
            budgets = []

            for item in data:
                category = get_object_or_404(Category, id=item['category_id'], user_id=user_id)
                budget = get_object_or_404(CategoryBudget, user_id=user_id, category=category)

                percentage = item.get("percentage", budget.percentage)
                budget.percentage = percentage
                budget.allocated_amount = (percentage / 100) * float(total_income)
                budgets.append(budget)

            total_allocated = sum(b.allocated_amount for b in budgets)
            leftover = float(total_income) - total_allocated

            if leftover > 0 and budgets:
                extra_per_budget = leftover / len(budgets)
                for b in budgets:
                    b.allocated_amount += extra_per_budget

            for b in budgets:
                b.save()

        return Response(
            {"message": "Budget updated successfully"},
            status=status.HTTP_200_OK
        )


class BalanceView(APIView):

    def get(self, request, user_id):
        total_income = Income.objects.filter(user_id=user_id).aggregate(
            total=Sum('amount')
        )['total'] or 0

        expenses = Expense.objects.filter(user_id=user_id)
        total_expense = sum(
            float(e.total_payment) + float(e.transaction_fee) for e in expenses
        )

        sent_transfers = Transfer.objects.filter(sender_id=user_id).aggregate(
            total=Sum('amount')
        )['total'] or 0

        received_transfers = Transfer.objects.filter(recipient_id=user_id).aggregate(
            total=Sum('amount')
        )['total'] or 0

        points_earned = Expense.objects.filter(user_id=user_id).aggregate(
            total=Sum('kusaku_points')
        )['total'] or 0

        points_spent = UserStamp.objects.filter(user_id=user_id).aggregate(
            total=Sum('points_used')
        )['total'] or 0

        balance = float(total_income) - total_expense - float(sent_transfers) + float(received_transfers)

        return Response({
            "total_income": float(total_income),
            "total_expense": total_expense,
            "balance": balance,
            "kusaku_points": int((points_earned or 0) - (points_spent or 0)),
        })


class ExpenseView(APIView):

    def get(self, request, user_id):
        expenses = Expense.objects.filter(user_id=user_id)
        return Response(ExpenseSerializer(expenses, many=True).data)

    def post(self, request, user_id):
        serializer = ExpenseSerializer(data=request.data)
        if serializer.is_valid():
            expense = serializer.save(user_id=user_id)

            try:
                budget = CategoryBudget.objects.get(
                    user_id=user_id,
                    category=expense.category
                )
            except CategoryBudget.DoesNotExist:
                return Response(serializer.data, status=201)

            total_spent = float(expense.total_payment) + float(expense.transaction_fee)
            budget.used_amount = float(budget.used_amount) + total_spent
            budget.save()

            return Response(serializer.data, status=201)

        return Response(serializer.errors, status=400)


class IncomeView(APIView):

    def get(self, request, user_id):
        incomes = Income.objects.filter(user_id=user_id)
        return Response(IncomeSerializer(incomes, many=True).data)

    def post(self, request, user_id):
        serializer = IncomeSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user_id=user_id)
            return Response(serializer.data, status=201)
        return Response(serializer.errors, status=400)


class TransferView(APIView):

    def post(self, request, user_id):
        sender_phone = request.data.get('sender_phone')
        recipient_phone = request.data.get('recipient_phone')
        amount = request.data.get('amount')
        notes = request.data.get('notes', '')

        if not all([sender_phone, recipient_phone, amount]):
            return Response(
                {"error": "sender_phone, recipient_phone, dan amount wajib diisi"},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            sender = Account.objects.get(id=user_id, phone_number=sender_phone)
        except Account.DoesNotExist:
            return Response(
                {"error": "Nomor pengirim tidak valid"},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            recipient = Account.objects.get(phone_number=recipient_phone)
        except Account.DoesNotExist:
            return Response(
                {"error": "Nomor penerima tidak ditemukan"},
                status=status.HTTP_404_NOT_FOUND
            )

        if sender == recipient:
            return Response(
                {"error": "Tidak bisa transfer ke diri sendiri"},
                status=status.HTTP_400_BAD_REQUEST
            )

        total_income = Income.objects.filter(user=sender).aggregate(
            total=Sum('amount')
        )['total'] or 0

        expenses = Expense.objects.filter(user=sender)
        total_expense = sum(
            float(e.total_payment) + float(e.transaction_fee) for e in expenses
        )

        sent_transfers = Transfer.objects.filter(sender=sender).aggregate(
            total=Sum('amount')
        )['total'] or 0

        received_transfers = Transfer.objects.filter(recipient=sender).aggregate(
            total=Sum('amount')
        )['total'] or 0

        balance = (
            float(total_income)
            - total_expense
            - float(sent_transfers)
            + float(received_transfers)
        )

        if balance < float(amount):
            return Response(
                {"error": "Saldo tidak cukup", "balance": balance},
                status=status.HTTP_400_BAD_REQUEST
            )

        # ✅ FIXED: Only create the Transfer record.
        # Do NOT create Expense for sender or Income for recipient here —
        # BalanceView already accounts for transfers via sent_transfers /
        # received_transfers, so creating those records would double-count.
        with transaction.atomic():
            transfer = Transfer.objects.create(
                sender=sender,
                recipient=recipient,
                amount=amount,
                notes=notes,
            )

        return Response({
            "message": "Transfer berhasil",
            "transfer_id": transfer.id,
            "amount": amount,
            "recipient": recipient.phone_number,
            "remaining_balance": balance - float(amount),
        }, status=status.HTTP_201_CREATED)


class UserCategoryBudgetView(APIView):

    def get(self, request, user_id):
        user = get_object_or_404(Account, pk=user_id)

        categories = Category.objects.filter(user=user)
        budgets_map = {
            b.category_id: b
            for b in CategoryBudget.objects.filter(user=user, category__in=categories)
        }

        result = []
        for cat in categories:
            budget = budgets_map.get(cat.id)
            result.append({
                "id": cat.id,
                "name": cat.name,
                "percentage": budget.percentage if budget else 0,
                "enabled": cat.is_active,
            })

        return Response(result)


class TransferLookupView(APIView):
    """Resolve a phone number to a display name before transfer."""
    def get(self, request):
        phone = request.query_params.get('phone')
        if not phone:
            return Response({"error": "phone required"}, status=400)
        try:
            account = Account.objects.get(phone_number=phone)
            return Response({
                "phone_number": account.phone_number,
                "name": account.username,
            })
        except Account.DoesNotExist:
            return Response({"error": "User not found"}, status=404)


class TransferHistoryView(APIView):
    """List sent and received transfers for a user."""
    def get(self, request, user_id):
        sent = Transfer.objects.filter(sender_id=user_id).select_related('recipient')
        received = Transfer.objects.filter(recipient_id=user_id).select_related('sender')

        def fmt(t, direction):
            counterpart = t.recipient if direction == 'sent' else t.sender
            return {
                "id": t.id,
                "direction": direction,
                "counterpart_phone": counterpart.phone_number,
                "counterpart_name": counterpart.username,
                "amount": float(t.amount),
                "notes": t.notes,
                "date": t.date.isoformat(),
            }

        history = (
            [fmt(t, 'sent') for t in sent] +
            [fmt(t, 'received') for t in received]
        )
        history.sort(key=lambda x: x['date'], reverse=True)

        return Response(history)