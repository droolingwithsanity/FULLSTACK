import subprocess
import os

print("\n🧠 LillyOS Auto-Fix Starting...\n")

NGINX_CONF = "/etc/nginx/conf.d/default.conf"

correct_config = """
server {
    listen 80;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri /index.html;
    }

    location /chat {
        proxy_pass http://lilly_backend:3000/chat;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /models {
        proxy_pass http://lilly_backend:3000/models;
    }

    location /stt {
        proxy_pass http://lilly_backend:3000/stt;
    }

    location /tts {
        proxy_pass http://lilly_backend:3000/tts;
    }

    client_max_body_size 20M;
}
"""

# ----------------------------
# 1. Detect frontend container
# ----------------------------
print("🔍 Checking containers...")

containers = subprocess.getoutput("docker ps --format '{{.Names}}'")

if "lilly_backend" not in containers:
    print("❌ Backend container missing!")
    exit(1)

if "lilly_frontend" not in containers:
    print("❌ Frontend container missing!")
    exit(1)

print("✔ Containers found")

# ----------------------------
# 2. Write nginx config INSIDE container
# ----------------------------
print("🛠 Updating nginx config...")

with open("default.conf", "w") as f:
    f.write(correct_config.strip())

subprocess.run(
    "docker cp default.conf lilly_frontend:/etc/nginx/conf.d/default.conf",
    shell=True,
    check=True
)

print("✔ Config copied")

# ----------------------------
# 3. Restart nginx container
# ----------------------------
print("🔄 Restarting frontend (nginx)...")

subprocess.run("docker restart lilly_frontend", shell=True, check=True)

# ----------------------------
# 4. Test backend connectivity
# ----------------------------
print("🧪 Testing backend connectivity...")

test = subprocess.getoutput(
    "docker exec lilly_frontend wget -qO- http://lilly_backend:3000/"
)

if test:
    print("✔ Backend reachable from nginx")
else:
    print("❌ Backend still unreachable")

print("\n🚀 LillyOS nginx FIX COMPLETE\n")
