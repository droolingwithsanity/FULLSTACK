from cryptography.fernet import Fernet
import os

KEY_PATH = "memory/key.key"

if not os.path.exists(KEY_PATH):
    key = Fernet.generate_key()
    open(KEY_PATH,"wb").write(key)

key = open(KEY_PATH,"rb").read()
cipher = Fernet(key)

def store_encrypted(text):
    encrypted = cipher.encrypt(text.encode())
    with open("memory/longterm.bin","ab") as f:
        f.write(encrypted + b"\n")
