import requests
from django.conf import settings

def send_to_ai(conversation: list) -> str:
    response = requests.post(
        "https://openrouter.ai/api/v1/chat/completions",
        headers={
            "Authorization": f"Bearer {settings.OPENROUTER_API_KEY}",
            "Content-Type": "application/json",
        },
        json={
            "model": "openai/gpt-4o-mini",
            "messages": conversation
        }
    )

    data = response.json()

    if "choices" not in data:
        raise Exception(data)

    return data["choices"][0]["message"]["content"]