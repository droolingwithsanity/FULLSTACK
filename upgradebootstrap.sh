#!/bin/bash
set -e

echo "🧠 Deploying LILLY v2 Sovereign AI..."

mkdir -p lilly_v2/{backend,frontend,models/{ollama,piper,whisper},backend/{plugins,memory,vector,services}}
cd lilly_v2

############################################
# DOCKER COMPOSE
############################################

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
    restart: unless-stopped
EOF

############################################
# BACKEND DOCKERFILE
############################################

cat <<'EOF' > backend/Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY . .
RUN apt-get update && apt-get install -y ffmpeg && \
    pip install --no-cache-dir fastapi uvicorn requests \
    numpy soundfile paho-mqtt faiss-cpu openai-whisper
CMD ["uvicorn","main:app","--host","0.0.0.0","--port","8000"]
EOF

############################################
# BACKEND CORE
############################################

cat <<'EOF' > backend/main.py
import os, socket, base64, requests, whisper, numpy as np
from fastapi import FastAPI, UploadFile
from pydantic import BaseModel
from memory.night_train import distill_memory
from vector.store import vector_memory
from plugins.manager import plugin_manager
from services.mqtt import mqtt_client

OLLAMA_URL = os.getenv("OLLAMA_URL")
PIPER_HOST = os.getenv("PIPER_HOST")
PIPER_PORT = int(os.getenv("PIPER_PORT"))

whisper_model = whisper.load_model("base")

app = FastAPI()

class ChatRequest(BaseModel):
    message: str
    persona: str = "You are Lilly, a sovereign local AI."

def call_ollama(prompt):
    r = requests.post(f"{OLLAMA_URL}/api/generate",
        json={"model":"llama3.2:1b","prompt":prompt,"stream":False})
    return r.json()["response"]

def call_piper(text):
    s=socket.socket()
    s.connect((PIPER_HOST,PIPER_PORT))
    s.sendall(text.encode())
    audio=s.recv(10000000)
    s.close()
    return base64.b64encode(audio).decode()

@app.post("/chat")
def chat(req: ChatRequest):
    memory_context = vector_memory.search(req.message)
    prompt = f"{req.persona}\nMemory:{memory_context}\nUser:{req.message}\nLilly:"
    response = call_ollama(prompt)

    vector_memory.store(req.message)
    distill_memory(req.message)

    plugin_manager.process(req.message)
    mqtt_client.publish("lilly/events", req.message)

    audio = call_piper(response)

    return {
        "text": response,
        "audio": f"data:audio/wav;base64,{audio}"
    }

@app.post("/stt")
async def stt(file: UploadFile):
    audio_bytes = await file.read()
    with open("temp.wav","wb") as f:
        f.write(audio_bytes)
    result = whisper_model.transcribe("temp.wav")
    return {"text": result["text"]}
EOF

############################################
# VECTOR MEMORY (FAISS)
############################################

cat <<'EOF' > backend/vector/store.py
import faiss, numpy as np

index = faiss.IndexFlatL2(384)
memory = []

def embed(text):
    vec = np.random.rand(384).astype("float32")
    return vec

def store(text):
    vec = embed(text)
    index.add(np.array([vec]))
    memory.append(text)

def search(text):
    if len(memory)==0:
        return ""
    vec = embed(text)
    D,I = index.search(np.array([vec]),1)
    return memory[I[0][0]]
EOF

############################################
# NIGHT DISTILLATION
############################################

cat <<'EOF' > backend/memory/night_train.py
import datetime

def distill_memory(message):
    day=datetime.datetime.now().strftime("%A")
    distilled=f"{day}: key signal -> {message[:60]}"
    with open("memory/distilled.txt","a") as f:
        f.write(distilled+"\n")
EOF

############################################
# MQTT SERVICE
############################################

cat <<'EOF' > backend/services/mqtt.py
import paho.mqtt.client as mqtt

mqtt_client = mqtt.Client()
try:
    mqtt_client.connect("localhost",1883,60)
except:
    pass
EOF

############################################
# PLUGIN MANAGER HOT RELOAD
############################################

cat <<'EOF' > backend/plugins/manager.py
import os, importlib

class PluginManager:
    def __init__(self):
        self.plugins={}
        self.load()

    def load(self):
        for f in os.listdir("plugins"):
            if f.endswith(".py") and f!="manager.py":
                name=f[:-3]
                mod=importlib.import_module(f"plugins.{name}")
                self.plugins[name]=mod

    def process(self,message):
        for p in self.plugins.values():
            if hasattr(p,"run"):
                p.run(message)

plugin_manager=PluginManager()
EOF

############################################
# SAMPLE SMART HOME PLUGIN
############################################

cat <<'EOF' > backend/plugins/home.py
def run(message):
    if "lights on" in message.lower():
        print("Turning lights on (MQTT trigger)")
EOF

############################################
# FRONTEND (White / Black UI + Ferrofluid + Mic)
############################################

mkdir -p frontend/src

cat <<'EOF' > frontend/package.json
{
  "name":"lilly",
  "private":true,
  "version":"1.0.0",
  "type":"module",
  "scripts":{"dev":"vite"},
  "dependencies":{
    "react":"^18.2.0",
    "react-dom":"^18.2.0",
    "p5":"^1.9.0"
  },
  "devDependencies":{
    "vite":"^5.0.0",
    "@vitejs/plugin-react":"^4.0.0"
  }
}
EOF

cat <<'EOF' > frontend/vite.config.js
import {defineConfig} from 'vite'
import react from '@vitejs/plugin-react'
export default defineConfig({plugins:[react()],server:{host:true}})
EOF

cat <<'EOF' > frontend/index.html
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Lilly</title></head>
<body style="margin:0;background:white;color:black;font-family:sans-serif;">
<div id="root"></div>
<script type="module" src="/src/main.jsx"></script>
</body>
</html>
EOF

cat <<'EOF' > frontend/src/main.jsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App'
ReactDOM.createRoot(document.getElementById('root')).render(<App/>)
EOF

cat <<'EOF' > frontend/src/App.jsx
import {useState,useRef} from "react"
import Visualizer from "./Visualizer"

export default function App(){
 const [isSpeaking,setIsSpeaking]=useState(false)
 const [msg,setMsg]=useState("")
 const mediaRef=useRef(null)

 const speak=(base64)=>{
  const a=new Audio(base64)
  setIsSpeaking(true)
  a.play()
  a.onended=()=>setIsSpeaking(false)
 }

 const send=async(text)=>{
  const r=await fetch("/chat",{method:"POST",
  headers:{"Content-Type":"application/json"},
  body:JSON.stringify({message:text})})
  const d=await r.json()
  speak(d.audio)
 }

 const record=async()=>{
  const stream=await navigator.mediaDevices.getUserMedia({audio:true})
  const rec=new MediaRecorder(stream)
  let chunks=[]
  rec.ondataavailable=e=>chunks.push(e.data)
  rec.onstop=async()=>{
    const blob=new Blob(chunks)
    const form=new FormData()
    form.append("file",blob)
    const r=await fetch("/stt",{method:"POST",body:form})
    const d=await r.json()
    send(d.text)
  }
  rec.start()
  setTimeout(()=>rec.stop(),3000)
 }

 return(
  <div style={{padding:20}}>
   <h1>Lilly</h1>
   <Visualizer isSpeaking={isSpeaking}/>
   <input value={msg} onChange={e=>setMsg(e.target.value)}/>
   <button onClick={()=>send(msg)}>Send</button>
   <button onClick={record}>🎤</button>
  </div>
 )
}
EOF

cat <<'EOF' > frontend/src/Visualizer.jsx
import {useEffect,useRef} from "react"
import p5 from "p5"

export default function Visualizer({isSpeaking}){
 const ref=useRef()
 useEffect(()=>{
  const sketch=p=>{
   let t=0
   const baseRadius=180
   p.setup=()=>p.createCanvas(500,500)
   p.draw=()=>{
    p.background(255)
    p.translate(250,250)
    p.stroke(0)
    p.noFill()
    p.circle(0,0,360)
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

############################################
# DOWNLOAD MODELS
############################################

cd models/piper
wget -q https://huggingface.co/rhasspy/piper-voices/resolve/main/en_US-amy-low.onnx
wget -q https://huggingface.co/rhasspy/piper-voices/resolve/main/en_US-amy-low.onnx.json
mv en_US-amy-low.onnx lilly_voice.onnx
mv en_US-amy-low.onnx.json lilly_voice.onnx.json
cd ../../

docker run --rm -v $(pwd)/models/ollama:/root/.ollama ollama/ollama pull llama3.2:1b

############################################
# BUILD & START
############################################

docker-compose build
docker-compose up -d

echo "🟢 LILLY v2 ONLINE at http://localhost:3000"
