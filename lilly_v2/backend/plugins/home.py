def run(message):
    if "lights on" in message.lower():
        print("Turning lights on (MQTT trigger)")
