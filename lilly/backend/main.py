import os
import socket
import base64
import requests
from fastapi import FastAPI
from pydantic import BaseModel
from plugins.manager import plugin_manager
from memory.night_train import summarize_memory

OLLAMA_URL = os.getenv("OLLAMA_URL")
PIPER_HOST = os.getenv("PIPER_HOST")
PIPER_PORT = int(os.getenv("PIPER_PORT"))

app = FastAPI()

class ChatRequest(BaseModel):
    message: str
    persona: str = "You are Lilly, a calm intelligent home assistant."

def call_ollama(prompt):
    response = requests.post(
        f"{OLLAMA_URL}/api/generate",
        json={"model": "llama3.2:1b", "prompt": prompt, "stream": False}
    )
    return response.json()["response"]

def call_piper(text):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((PIPER_HOST, PIPER_PORT))
    sock.sendall(text.encode())
    audio = sock.recv(10000000)
    sock.close()
    return base64.b64encode(audio).decode()

@app.post("/chat")
def chat(req: ChatRequest):
    memory_summary = summarize_memory(req.message)
    prompt = f"{req.persona}\nMemory:{memory_summary}\nUser:{req.message}\nLilly:"
    text_response = call_ollama(prompt)
    plugin_manager.process(req.message)
    audio_base64 = call_piper(text_response)

    return {
        "text": text_response,
        "audio": f"data:audio/wav;base64,{audio_base64}"
    }

@app.get("/plugins")
def list_plugins():
    return plugin_manager.list_plugins()

@app.post("/plugins/enable/{name}")
def enable_plugin(name: str):
    plugin_manager.enable(name)
    return {"status": "enabled"}

@app.post("/plugins/disable/{name}")
def disable_plugin(name: str):
    plugin_manager.disable(name)
    return {"status": "disabled"}
