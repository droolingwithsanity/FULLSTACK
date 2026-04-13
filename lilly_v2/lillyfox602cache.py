import subprocess

print("\n🧠 LillyOS 502 AUTO-REPAIR STARTING...\n")

NGINX_CONFIG = """
server {
    listen 80;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri /index.html;
    }

    location /chat {
        proxy_pass http://lilly_backend:3000/chat;
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
}
"""

# -------------------------
# 1. Write clean config
# -------------------------
with open("default.conf", "w") as f:
    f.write(NGINX_CONFIG)

print("✔ Clean nginx config generated")

# -------------------------
# 2. Inject into container
# -------------------------
print("📦 Copying config into nginx container...")

subprocess.run(
    "docker cp default.conf lilly_frontend:/etc/nginx/conf.d/default.conf",
    shell=True,
    check=True
)

# -------------------------
# 3. IMPORTANT: clear old nginx cache inside container
# -------------------------
print("🧹 Clearing nginx cache...")

subprocess.run(
    "docker exec lilly_frontend nginx -s reload",
    shell=True,
    check=True
)

# -------------------------
# 4. Restart frontend fully (safest fix)
# -------------------------
print("🔄 Restarting frontend container...")

subprocess.run(
    "docker restart lilly_frontend",
    shell=True,
    check=True
)

# -------------------------
# 5. Test backend from inside nginx
# -------------------------
print("🧪 Testing backend connectivity from nginx...")

test = subprocess.getoutput(
    "docker exec lilly_frontend wget -qO- http://lilly_backend:3000/"
)

if "error" in test.lower() or test.strip() == "":
    print("❌ Backend still NOT reachable from nginx")
    print("👉 Network issue between containers")
else:
    print("✔ Backend reachable OK")

print("\n🚀 502 AUTO-REPAIR COMPLETE\n")
