#!/bin/bash
set -e

echo "🔁 Upgrading Lilly v2 → v3 Autonomous Core"

cd backend

mkdir -p agent
mkdir -p memory

########################################
# AGENT ORCHESTRATOR
########################################

cat <<'EOF' > agent/orchestrator.py
from agent.planner import create_plan
from agent.reflector import reflect
from memory.vector_store import retrieve_context, store_vector
from memory.encrypted_store import store_encrypted
from llm import ask_llm
from plugins.manager import plugin_manager

class Agent:

    def handle(self, user_input, persona):

        context = retrieve_context(user_input)

        plan = create_plan(user_input, context)

        tool_result = plugin_manager.process(user_input)

        if tool_result:
            response = tool_result
        else:
            prompt = f"{persona}\nContext:{context}\nUser:{user_input}\nPlan:{plan}\nLilly:"
            response = ask_llm(prompt)

        reflection = reflect(user_input, response)

        store_vector(user_input)
        store_encrypted(reflection)

        return response

agent = Agent()
EOF

########################################
# PLANNER
########################################

cat <<'EOF' > agent/planner.py
from llm import ask_llm

def create_plan(user_input, context):
    prompt = f"""
Break the request into structured execution steps.

Request: {user_input}
Context: {context}
Return concise numbered steps.
"""
    return ask_llm(prompt)
EOF

########################################
# REFLECTOR
########################################

cat <<'EOF' > agent/reflector.py
from llm import ask_llm

def reflect(user_input, response):
    prompt = f"""
Evaluate the response quality and extract improvement signals.
User: {user_input}
Response: {response}
Return distilled learning signals only.
"""
    return ask_llm(prompt)
EOF

########################################
# BACKGROUND THINKER
########################################

cat <<'EOF' > agent/thinker.py
import threading
import time
from llm import ask_llm
from memory.encrypted_store import store_encrypted

def think_loop():
    while True:
        reflection = ask_llm("Privately reflect on today and improve future reasoning.")
        store_encrypted(reflection)
        time.sleep(3600)

def start_background_thinker():
    t = threading.Thread(target=think_loop, daemon=True)
    t.start()
EOF

########################################
# REAL VECTOR MEMORY (SENTENCE TRANSFORMER)
########################################

cat <<'EOF' > memory/vector_store.py
import faiss
import numpy as np
from sentence_transformers import SentenceTransformer

model = SentenceTransformer("all-MiniLM-L6-v2")
dimension = 384
index = faiss.IndexFlatL2(dimension)
memory_text = []

def store_vector(text):
    vec = model.encode([text])[0].astype("float32")
    index.add(np.array([vec]))
    memory_text.append(text)

def retrieve_context(query):
    if len(memory_text) == 0:
        return ""
    vec = model.encode([query])[0].astype("float32")
    D,I = index.search(np.array([vec]),1)
    return memory_text[I[0][0]]
EOF

########################################
# ENCRYPTED LONG TERM MEMORY
########################################

cat <<'EOF' > memory/encrypted_store.py
from cryptography.fernet import Fernet
import os

KEY_PATH = "memory/key.key"

if not os.path.exists(KEY_PATH):
    key = Fernet.generate_key()
    open(KEY_PATH,"wb").write(key)

key = open(KEY_PATH,"rb").read()
cipher = Fernet(key)

def store_encrypted(text):
    encrypted = cipher.encrypt(text.encode())
    with open("memory/longterm.bin","ab") as f:
        f.write(encrypted + b"\n")
EOF

########################################
# NIGHT LEARNING CYCLE (REAL IMPLEMENTATION)
########################################

cat <<'EOF' > memory/night_cycle.py
import schedule
import time
from llm import ask_llm
from memory.encrypted_store import store_encrypted

def night_learning():
    with open("memory/longterm.bin","rb") as f:
        content = f.read().decode(errors="ignore")

    prompt = f"""
Distill the following reflections into high-level knowledge.
Remove noise. Extract stable patterns only.

Data:
{content}
"""
    distilled = ask_llm(prompt)
    store_encrypted("DISTILLED:" + distilled)

schedule.every().day.at("02:00").do(night_learning)

def start_night_cycle():
    while True:
        schedule.run_pending()
        time.sleep(60)
EOF

########################################
# LLM WRAPPER
########################################

cat <<'EOF' > llm.py
import os, requests

OLLAMA_URL = os.getenv("OLLAMA_URL")

def ask_llm(prompt):
    r = requests.post(
        f"{OLLAMA_URL}/api/generate",
        json={"model":"llama3.2:1b","prompt":prompt,"stream":False}
    )
    return r.json()["response"]
EOF

########################################
# PATCH MAIN.PY TO USE AGENT
########################################

cat <<'EOF' > main.py
import os, socket, base64
from fastapi import FastAPI
from pydantic import BaseModel
from agent.orchestrator import agent
from agent.thinker import start_background_thinker
from memory.night_cycle import start_night_cycle

PIPER_HOST = os.getenv("PIPER_HOST")
PIPER_PORT = int(os.getenv("PIPER_PORT"))

app = FastAPI()

class ChatRequest(BaseModel):
    message: str
    persona: str = "You are Lilly v3 autonomous."

def call_piper(text):
    s=socket.socket()
    s.connect((PIPER_HOST,PIPER_PORT))
    s.sendall(text.encode())
    audio=s.recv(10000000)
    s.close()
    return base64.b64encode(audio).decode()

@app.on_event("startup")
def startup():
    start_background_thinker()
    import threading
    threading.Thread(target=start_night_cycle, daemon=True).start()

@app.post("/chat")
def chat(req: ChatRequest):
    response = agent.handle(req.message, req.persona)
    audio = call_piper(response)
    return {
        "text": response,
        "audio": f"data:audio/wav;base64,{audio}"
    }
EOF

########################################
# UPDATE DOCKERFILE DEPENDENCIES
########################################

cat <<'EOF' > Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY . .
RUN apt-get update && apt-get install -y ffmpeg && \
    pip install --no-cache-dir fastapi uvicorn requests \
    numpy faiss-cpu sentence-transformers \
    cryptography schedule paho-mqtt openai-whisper
CMD ["uvicorn","main:app","--host","0.0.0.0","--port","8000"]
EOF

echo "🔨 Rebuilding backend..."
cd ..
docker compose build backend
docker compose up -d

echo "🧠 Lilly v3 Autonomous Core Online"
