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
