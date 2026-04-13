import paho.mqtt.client as mqtt

mqtt_client = mqtt.Client()
try:
    mqtt_client.connect("localhost",1883,60)
except:
    pass
