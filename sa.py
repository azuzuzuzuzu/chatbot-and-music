import requests

API_KEY = "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"

headers = {
    "Authorization": f"Bearer {API_KEY}"
}

r = requests.get(
    "https://openrouter.ai/api/v1/models",
    headers=headers
)

print(r.status_code)
print(r.text[:500])