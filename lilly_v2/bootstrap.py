import os
import subprocess
from pathlib import Path

BASE = Path.cwd()

print("\n🧠 LillyOS Bootstrap Upgrade Starting...\n")

# ----------------------------
# 1. Ensure frontend env flags
# ----------------------------
frontend_env = BASE / "frontend/.env"

env_content = """
VITE_LILLY_MOBILE=1
VITE_LILLY_STREAMING=1
VITE_LILLY_VOICE=1
"""

frontend_env.parent.mkdir(parents=True, exist_ok=True)
frontend_env.write_text(env_content.strip())
print("✔ Frontend env configured")

# ----------------------------
# 2. Ensure backend feature flags
# ----------------------------
backend_env = BASE / "backend/.env"

backend_env_content = """
LILLY_STREAMING=1
LILLY_TTS=1
LILLY_STT=1
OLLAMA_FALLBACK=1
"""

backend_env.parent.mkdir(parents=True, exist_ok=True)
backend_env.write_text(backend_env_content.strip())
print("✔ Backend env configured")

# ----------------------------
# 3. Create TTS endpoint stub (FastAPI-ready)
# ----------------------------
tts_file = BASE / "backend/tts_stub.py"

tts_code = """
from fastapi import APIRouter
import subprocess

router = APIRouter()

@router.post("/tts")
async def tts(data: dict):
    text = data.get("text", "")
    
    # Piper CLI hook (host-based)
    subprocess.Popen(["echo", text])
    
    return {"status": "ok", "spoken": text}
"""

tts_file.write_text(tts_code.strip())
print("✔ TTS stub created")

# ----------------------------
# 4. Ensure nginx safe restart script
# ----------------------------
nginx_restart = BASE / "restart_nginx.sh"

nginx_script = """#!/bin/bash
echo "Restarting LillyOS frontend..."
docker restart lilly_frontend
echo "Done."
"""

nginx_restart.write_text(nginx_script.strip())
os.chmod(nginx_restart, 0o755)

print("✔ Nginx restart script ready")

# ----------------------------
# 5. Health check script
# ----------------------------
health = BASE / "healthcheck.sh"

health_script = """#!/bin/bash
echo "Checking LillyOS services..."

curl -s http://localhost:3000/ && echo "✔ Backend OK" || echo "❌ Backend DOWN"
curl -s http://localhost:81/ && echo "✔ Frontend OK" || echo "❌ Frontend DOWN"

echo "Done."
"""

health.write_text(health_script.strip())
os.chmod(health, 0o755)

print("✔ Healthcheck script created")

# ----------------------------
# 6. Docker restart automation
# ----------------------------
restart = BASE / "restart_all.sh"

restart_script = """#!/bin/bash
echo "Rebuilding LillyOS stack..."

docker compose down
docker compose up --build -d

echo "✔ LillyOS restarted"
"""

restart.write_text(restart_script.strip())
os.chmod(restart, 0o755)

print("✔ Full restart script created")

# ----------------------------
# 7. Final message
# ----------------------------
print("\n🚀 LillyOS Upgrade Bootstrap COMPLETE")
print("Next steps:")
print("  ./restart_all.sh")
print("  ./healthcheck.sh")
print("\n🧠 System now ready for voice + mobile + streaming upgrades\n")
