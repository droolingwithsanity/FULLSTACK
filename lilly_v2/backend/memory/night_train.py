import datetime

def distill_memory(message):
    day=datetime.datetime.now().strftime("%A")
    distilled=f"{day}: key signal -> {message[:60]}"
    with open("memory/distilled.txt","a") as f:
        f.write(distilled+"\n")
