import schedule
import time
from llm import ask_llm
from memory.encrypted_store import store_encrypted

def night_learning():
    with open("memory/longterm.bin","rb") as f:
        content = f.read().decode(errors="ignore")

    prompt = f"""
Distill the following reflections into high-level knowledge.
Remove noise. Extract stable patterns only.

Data:
{content}
"""
    distilled = ask_llm(prompt)
    store_encrypted("DISTILLED:" + distilled)

schedule.every().day.at("02:00").do(night_learning)

def start_night_cycle():
    while True:
        schedule.run_pending()
        time.sleep(60)
