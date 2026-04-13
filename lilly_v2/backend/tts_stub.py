from fastapi import APIRouter
import subprocess

router = APIRouter()

@router.post("/tts")
async def tts(data: dict):
    text = data.get("text", "")
    
    # Piper CLI hook (host-based)
    subprocess.Popen(["echo", text])
    
    return {"status": "ok", "spoken": text}