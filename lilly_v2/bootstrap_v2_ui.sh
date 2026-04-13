#!/bin/bash

set -e

ROOT="/home/labhrasd/FULLSTACK/lilly_v2"
cd "$ROOT"

echo "🧠 Lilly V2 UI Bootstrap Starting..."

# ---------------------------------------
# 1. Fix nginx (API proxy layer)
# ---------------------------------------
echo "🔧 Fixing nginx.conf..."

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


# ---------------------------------------
# 2. Restore ChatGPT-style App WITH Visualization
# ---------------------------------------
echo "🎨 Restoring App.jsx with Visualization..."

cat > frontend/src/App.jsx << 'EOF'
import { useState, useRef, useEffect } from "react";
import Visualization from "./Visualizer";

export default function App() {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState("");
  const [aiState, setAiState] = useState("idle");

  const bottomRef = useRef(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages, aiState]);

  const send = async () => {
    if (!input.trim()) return;

    const text = input;
    setInput("");

    setMessages((m) => [...m, { role: "user", text }]);

    setAiState("thinking");

    const res = await fetch("/api/chat", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ prompt: text })
    });

    const data = await res.json();

    setMessages((m) => [
      ...m,
      { role: "assistant", text: data.response || "" }
    ]);

    setAiState("idle");
  };

  return (
    <div style={styles.page}>

      {/* 🧠 VISUAL BRAIN */}
      <Visualization state={aiState} />

      {/* 💬 CHAT */}
      <div style={styles.chat}>
        {messages.map((m, i) => (
          <div
            key={i}
            style={{
              ...styles.msg,
              alignSelf: m.role === "user" ? "flex-end" : "flex-start"
            }}
          >
            {m.text}
          </div>
        ))}

        {aiState === "thinking" && (
          <div style={styles.typing}>Lilly is thinking...</div>
        )}

        <div ref={bottomRef} />
      </div>

      {/* INPUT */}
      <div style={styles.inputBar}>
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && send()}
          placeholder="Message Lilly..."
          style={styles.input}
        />
      </div>
    </div>
  );
}

const styles = {
  page: {
    height: "100vh",
    display: "flex",
    flexDirection: "column",
    background: "white",
    fontFamily: "system-ui"
  },

  chat: {
    flex: 1,
    padding: 20,
    display: "flex",
    flexDirection: "column",
    gap: 12,
    overflowY: "auto"
  },

  msg: {
    maxWidth: "700px",
    padding: "10px 14px",
    borderRadius: 10,
    fontSize: 16
  },

  typing: {
    color: "#888",
    fontStyle: "italic"
  },

  inputBar: {
    borderTop: "1px solid #eee",
    padding: 12
  },

  input: {
    width: "100%",
    padding: 14,
    border: "none",
    outline: "none",
    fontSize: 16
  }
};
EOF


# ---------------------------------------
# 3. Ensure Visualization supports state
# ---------------------------------------
echo "🎬 Updating Visualizer..."

cat > frontend/src/Visualizer.jsx << 'EOF'
import { useEffect } from "react";

export default function Visualization({ state }) {

  useEffect(() => {
    // hook for future animation logic
    console.log("AI STATE:", state);
  }, [state]);

  return (
    <div style={{
      height: 120,
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      fontSize: 14,
      color: "#999"
    }}>
      {state === "thinking" && "🧠 Lilly is processing..."}
      {state === "idle" && "⚪ Lilly is idle"}
      {state === "speaking" && "🔊 Lilly speaking"}
    </div>
  );
}
EOF


# ---------------------------------------
# 4. Validate frontend API consistency
# ---------------------------------------
echo "🔍 Validating API usage..."

if grep -q "/api/chat" frontend/src/App.jsx; then
    echo "✅ API routing correct"
else
    echo "❌ API routing missing"
fi


echo "🚀 Bootstrap complete"
echo "Run: docker-compose down && docker-compose up --build"
