cat > nginx.conf << 'EOF'
server {
    listen 80;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri /index.html;
    }

    location /api/ {
        proxy_pass http://lilly_backend:3000/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF
cat > frontend/src/App.jsx << 'EOF'
import { useState, useRef } from "react";
import Visualizer from "./Visualizer";
import Visualization from "./Visualization";

export default function App() {
  const [msg, setMsg] = useState("");
  const [isSpeaking, setIsSpeaking] = useState(false);

  const speak = (base64) => {
    const audio = new Audio(base64);
    setIsSpeaking(true);
    audio.play();
    audio.onended = () => setIsSpeaking(false);
  };

  const send = async (text) => {
    const r = await fetch("/api/chat", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ prompt: text })
    });

    const data = await r.json();

    setMsg(data.response || "");

    if (data.audio) {
      speak(data.audio);
    }
  };

  return (
    <div>
      <Visualization isSpeaking={isSpeaking} />
      <input
        placeholder="Talk to Lilly..."
        onKeyDown={(e) => {
          if (e.key === "Enter") send(e.target.value);
        }}
      />
      <p>{msg}</p>
    </div>
  );
}
EOF
cat > backend/ollama_config.py << 'EOF'
import os
import requests

OLLAMA_CANDIDATES = [
    "http://host.docker.internal:11435/api",
    "http://172.17.0.1:11435/api",
    "http://localhost:11435/api"
]

def get_ollama():
    for url in OLLAMA_CANDIDATES:
        try:
            r = requests.get(f"{url}/tags", timeout=2)
            if r.status_code == 200:
                return url
        except:
            continue
    return OLLAMA_CANDIDATES[0]

OLLAMA_URL = get_ollama()
EOF
cat > docker-compose.yml << 'EOF'
version: "3.9"

services:
  lilly_backend:
    build: ./backend
    container_name: lilly_backend
    ports:
      - "3000:3000"
    environment:
      - PYTHONUNBUFFERED=1
    extra_hosts:
      - "host.docker.internal:host-gateway"
    restart: unless-stopped

  lilly_frontend:
    build: ./frontend
    container_name: lilly_frontend
    ports:
      - "80:80"
    depends_on:
      - lilly_backend
    restart: unless-stopped
EOF

