import os
import json
import requests
from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware

# ----------------------------
# CONFIG
# ----------------------------
OLLAMA_CANDIDATES = [
    "http://host.docker.internal:11435/api",
    "http://172.17.0.1:11435/api",
    "http://localhost:11435/api",
]

def detect_ollama():
    for url in OLLAMA_CANDIDATES:
        try:
            r = requests.get(f"{url}/tags", timeout=2)
            if r.status_code == 200:
                print(f"[LILLY] Connected to Ollama at {url}")
                return url
        except:
            continue
    print("[LILLY] WARNING: Could not detect Ollama, defaulting...")
    return OLLAMA_CANDIDATES[0]

OLLAMA_BASE = os.getenv("OLLAMA_URL") or detect_ollama()

# ----------------------------
# APP INIT
# ----------------------------
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ----------------------------
# ROUTES
# ----------------------------

@app.get("/")
def root():
    return {"status": "Lilly backend running"}

# 🔥 MODEL LIST
@app.get("/models")
def list_models():
    try:
        r = requests.get(f"{OLLAMA_BASE}/tags", timeout=5)
        data = r.json()
        models = [m["name"] for m in data.get("models", [])]
        return {"models": models}
    except:
        return {"models": ["lilly"]}

# 🔥 CHAT (STREAMING WITH DONE SIGNAL)
@app.post("/chat")
async def chat(request: Request):
    data = await request.json()
    prompt = data.get("prompt", "")
    model = data.get("model", "lilly")

    def generate():
        try:
            payload = {
                "model": model,
                "prompt": prompt,
                "stream": True
            }

            with requests.post(
                f"{OLLAMA_BASE}/generate",
                json=payload,
                stream=True,
                timeout=120
            ) as r:

                for line in r.iter_lines():
                    if not line:
                        continue

                    chunk = json.loads(line.decode("utf-8"))

                    # Stream tokens
                    if "response" in chunk:
                        yield chunk["response"]

                    # 🔥 DONE SIGNAL
                    if chunk.get("done"):
                        yield "[DONE]"
                        break

        except Exception as e:
            yield f"[ERROR] {str(e)}[DONE]"

    return StreamingResponse(generate(), media_type="text/plain")
