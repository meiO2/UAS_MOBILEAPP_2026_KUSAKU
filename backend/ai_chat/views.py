from rest_framework.views import APIView
from rest_framework.response import Response
from .models import ChatSession, ChatMessage
from .serializers import ChatSessionSerializer
from .services.openrouter_service import send_to_ai
import json
import re


def is_budget_json_string(text):
    try:
        cleaned = re.sub(r'^```(?:json)?\s*|\s*```$', '', text.strip(), flags=re.MULTILINE).strip()
        parsed = json.loads(cleaned)
        return isinstance(parsed, dict) and len(parsed) > 0 and all(isinstance(v, (int, float)) for v in parsed.values()), cleaned
    except:
        return False, text


class ChatSessionView(APIView):
    def get(self, request, user_id):
        session, _ = ChatSession.objects.get_or_create(user_id=user_id)
        serializer = ChatSessionSerializer(session)
        return Response(serializer.data)


class InitBudgetView(APIView):
    def post(self, request, user_id):
        session, _ = ChatSession.objects.get_or_create(user_id=user_id)

        # Get user's categories to include in the prompt
        from transactions.models import Category  # adjust import to your app
        categories = Category.objects.filter(user_id=user_id)
        category_names = [c.name for c in categories]

        conversation = [
            {
                "role": "system",
                "content": (
                    "You are a financial assistant. The user has these budget categories: "
                    f"{', '.join(category_names)}.\n\n"
                    "Respond ONLY with a raw JSON object allocating percentages that add up to 100. "
                    "Example: {\"Makan & Minum\": 30, \"Transportasi\": 10}. "
                    "No explanation, no markdown, just the JSON."
                )
            },
            {
                "role": "user",
                "content": "Give me an initial budget recommendation for my categories."
            }
        ]

        ai_reply = send_to_ai(conversation)

        import json, re
        cleaned = re.sub(r'^```(?:json)?\s*|\s*```$', '', ai_reply.strip(), flags=re.MULTILINE).strip()

        try:
            parsed = json.loads(cleaned)
            return Response({
                "type": "budget_suggestion",
                "data": parsed
            })
        except:
            return Response({"type": "error", "data": {}})


class ChatMessageView(APIView):
    def post(self, request, user_id):
        session, _ = ChatSession.objects.get_or_create(user_id=user_id)

        user_message = request.data.get("message")

        # Store user message
        ChatMessage.objects.create(session=session, is_user=True, text=user_message)

        # Get last 10 messages
        messages = ChatMessage.objects.filter(session=session).order_by('-created_at')[:10][::-1]

        conversation = [
            {
                "role": "system",
                "content": (
                    "You are a friendly financial assistant. Help users with budgeting, "
                    "expenses, and financial advice. "
                    "Respond in plain conversational text only. "
                    "Never respond with JSON."
                )
            }
        ]

        for m in messages:
            conversation.append({
                "role": "user" if m.is_user else "assistant",
                "content": m.text
            })

        ai_reply = send_to_ai(conversation)

        # Store AI reply
        ChatMessage.objects.create(session=session, is_user=False, text=ai_reply)

        return Response({
            "reply": ai_reply,
            "type": "text"
        })