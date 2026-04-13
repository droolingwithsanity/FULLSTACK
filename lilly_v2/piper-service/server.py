from fastapi import FastAPI
from fastapi.responses import FileResponse
import subprocess

app = FastAPI()

PIPER = "/app/piper/piper"
MODEL = "/app/voices/en_US-amy-medium.onnx"
OUT = "/app/out.wav"

@app.get("/tts")
def tts(text: str):

    result = subprocess.run(
        [PIPER, "-m", MODEL, "-f", OUT],
        input=text.encode(),
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        return {
            "error": result.stderr,
            "stdout": result.stdout
        }

    return FileResponse(OUT, media_type="audio/wav")
