#!/bin/bash
set -e

echo "🚀 Deploying Lilly AI System..."

########################################
# STRUCTURE
########################################

mkdir -p lilly/{backend,frontend,models/piper,models/ollama,backend/plugins,backend/memory}
cd lilly

########################################
# DOCKER COMPOSE
########################################

cat <<'EOF' > docker-compose.yml
version: "3.9"

services:

  ollama:
    image: ollama/ollama:latest
    container_name: lilly_ollama
    ports:
      - "11434:11434"
    volumes:
      - ./models/ollama:/root/.ollama
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:11434"]
      interval: 30s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  piper:
    image: rhasspy/wyoming-piper:latest
    container_name: lilly_piper
    ports:
      - "10200:10200"
    volumes:
      - ./models/piper:/data
    command: >
      --voice lilly_voice
      --uri tcp://0.0.0.0:10200
    healthcheck:
      test: ["CMD", "nc", "-z", "localhost", "10200"]
      interval: 30s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  backend:
    build: ./backend
    container_name: lilly_backend
    network_mode: host
    environment:
      - OLLAMA_URL=http://127.0.0.1:11434
      - PIPER_HOST=127.0.0.1
      - PIPER_PORT=10200
    depends_on:
      - ollama
      - piper
    restart: unless-stopped

  frontend:
    build: ./frontend
    container_name: lilly_frontend
    ports:
      - "3000:3000"
    environment:
      - VITE_API_URL=http://127.0.0.1:8000
    restart: unless-stopped
EOF

########################################
# BACKEND DOCKERFILE
########################################

cat <<'EOF' > backend/Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir fastapi uvicorn requests
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

########################################
# BACKEND MAIN
########################################

cat <<'EOF' > backend/main.py
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
EOF

########################################
# PLUGIN MANAGER
########################################

cat <<'EOF' > backend/plugins/manager.py
import os
import importlib

class PluginManager:
    def __init__(self):
        self.plugins = {}
        self.load_plugins()

    def load_plugins(self):
        for file in os.listdir("plugins"):
            if file.endswith(".py") and file != "manager.py":
                name = file[:-3]
                module = importlib.import_module(f"plugins.{name}")
                self.plugins[name] = {"module": module, "enabled": True}

    def list_plugins(self):
        return {k: v["enabled"] for k,v in self.plugins.items()}

    def enable(self, name):
        self.plugins[name]["enabled"] = True

    def disable(self, name):
        self.plugins[name]["enabled"] = False

    def process(self, message):
        for p in self.plugins.values():
            if p["enabled"]:
                p["module"].run(message)

plugin_manager = PluginManager()
EOF

########################################
# SAMPLE PLUGIN
########################################

cat <<'EOF' > backend/plugins/learning.py
def run(message):
    print("Learning from:", message)
EOF

########################################
# MEMORY SYSTEM
########################################

cat <<'EOF' > backend/memory/night_train.py
import datetime

def summarize_memory(message):
    today = datetime.datetime.now().strftime("%A")
    summary = f"{today} key signal: {message[:50]}"
    with open("memory/log.txt", "a") as f:
        f.write(summary + "\n")
    return summary
EOF

########################################
# FRONTEND DOCKERFILE
########################################

cat <<'EOF' > frontend/Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY . .
RUN npm install
CMD ["npm","run","dev","--","--host"]
EOF

########################################
# FRONTEND PACKAGE.JSON
########################################

cat <<'EOF' > frontend/package.json
{
  "name": "lilly",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite"
  },
  "dependencies": {
    "p5": "^1.9.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.0.0",
    "vite": "^5.0.0"
  }
}
EOF

########################################
# VITE CONFIG
########################################

cat <<'EOF' > frontend/vite.config.js
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: { host: true, port: 3000 }
})
EOF

########################################
# FRONTEND INDEX
########################################

mkdir -p frontend/src

cat <<'EOF' > frontend/index.html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Lilly</title>
  </head>
  <body style="margin:0;background:white;color:black;">
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

########################################
# FRONTEND MAIN
########################################

cat <<'EOF' > frontend/src/main.jsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
ReactDOM.createRoot(document.getElementById('root')).render(<App />)
EOF

########################################
# FRONTEND APP
########################################

cat <<'EOF' > frontend/src/App.jsx
import { useState } from "react"
import Visualizer from "./Visualizer"

export default function App(){
  const [isSpeaking,setIsSpeaking]=useState(false)
  const [persona,setPersona]=useState("You are Lilly.")
  const [message,setMessage]=useState("")

  const initAudio=(base64)=>{
    const audio=new Audio(base64)
    setIsSpeaking(true)
    audio.play()
    audio.onended=()=>setIsSpeaking(false)
  }

  const send=async()=>{
    const res=await fetch("/chat",{
      method:"POST",
      headers:{"Content-Type":"application/json"},
      body:JSON.stringify({message,persona})
    })
    const data=await res.json()
    initAudio(data.audio)
  }

  return(
    <div style={{padding:20}}>
      <h1>Lilly</h1>
      <Visualizer isSpeaking={isSpeaking}/>
      <textarea value={persona} onChange={e=>setPersona(e.target.value)}/>
      <input value={message} onChange={e=>setMessage(e.target.value)}/>
      <button onClick={send}>Speak</button>
    </div>
  )
}
EOF

########################################
# FERROFLUID VISUALIZER
########################################

cat <<'EOF' > frontend/src/Visualizer.jsx
import { useEffect,useRef } from "react"
import p5 from "p5"

export default function Visualizer({isSpeaking}){
  const ref=useRef()

  useEffect(()=>{
    const sketch=(p)=>{
      let t=0
      const baseRadius=180

      p.setup=()=>p.createCanvas(500,500)

      p.draw=()=>{
        p.background(255)
        p.translate(p.width/2,p.height/2)
        p.noFill()
        p.stroke(0)
        p.circle(0,0,baseRadius*2)

        p.beginShape()
        for(let a=0;a<p.TWO_PI;a+=0.1){
          let n=p.noise(Math.cos(a)+t,Math.sin(a)+t)
          let r=baseRadius+n*(isSpeaking?40:10)
          p.vertex(r*Math.cos(a),r*Math.sin(a))
        }
        p.endShape(p.CLOSE)

        t+=isSpeaking?0.08:0.01
      }
    }

    const instance=new p5(sketch,ref.current)
    return()=>instance.remove()
  },[isSpeaking])

  return <div ref={ref}></div>
}
EOF

########################################
# DOWNLOAD PIPER VOICE
########################################

echo "Downloading Piper voice..."
cd models/piper
wget -q https://huggingface.co/rhasspy/piper-voices/resolve/main/en_US-amy-low.onnx
wget -q https://huggingface.co/rhasspy/piper-voices/resolve/main/en_US-amy-low.onnx.json
mv en_US-amy-low.onnx lilly_voice.onnx
mv en_US-amy-low.onnx.json lilly_voice.onnx.json
cd ../../

########################################
# PULL OLLAMA MODEL
########################################

docker run --rm -v $(pwd)/models/ollama:/root/.ollama ollama/ollama pull llama3.2:1b

########################################
# BUILD & START
########################################

docker-compose build
docker-compose up -d

echo "✅ Lilly is running on http://localhost:3000"
