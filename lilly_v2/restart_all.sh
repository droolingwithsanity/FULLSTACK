#!/bin/bash
echo "Rebuilding LillyOS stack..."

docker compose down
docker compose up --build -d

echo "✔ LillyOS restarted"