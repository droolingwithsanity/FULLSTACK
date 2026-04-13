import datetime

def summarize_memory(message):
    today = datetime.datetime.now().strftime("%A")
    summary = f"{today} key signal: {message[:50]}"
    with open("memory/log.txt", "a") as f:
        f.write(summary + "\n")
    return summary
