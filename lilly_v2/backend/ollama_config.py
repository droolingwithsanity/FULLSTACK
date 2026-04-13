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
                print(f"[LILLY] Connected to {url}")
                return url
        except:
            continue

    print("[LILLY] WARNING: fallback Ollama used")
    return OLLAMA_CANDIDATES[0]

OLLAMA_URL = get_ollama()
