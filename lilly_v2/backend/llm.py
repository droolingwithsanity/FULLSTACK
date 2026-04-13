import requests
import os

OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11435")

def ask_llm(prompt):
    r = requests.post(
        f"{OLLAMA_URL}/api/generate",
        json={
            "model": "llama3",
            "prompt": prompt,
            "stream": False
        }
    )

    data = r.json()

    # SAFE extraction (handles multiple Ollama formats)
    if "response" in data:
        return data["response"]

    if "message" in data:
        return data["message"]["content"]

    return str(data)
