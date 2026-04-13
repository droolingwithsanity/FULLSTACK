#!/bin/bash

set -e

echo "🔥 Cleaning old container/images..."
docker rm -f piper-service 2>/dev/null || true
docker rmi -f piper-service 2>/dev/null || true

echo "📦 Building Docker image..."

docker build -t piper-service -f piper-service/Dockerfile piper-service

echo "🚀 Starting container..."

CID=$(docker run -d -p 5005:5005 piper-service)

echo "Container ID: $CID"

echo "⏳ Waiting for startup..."
sleep 3

echo "🧪 Testing Piper inside container..."

docker exec -it $CID bash -c "
ls -R /app && \
echo 'hello docker test' | /app/piper/piper \
  -m /app/voices/en_US-amy-medium.onnx \
  -f /app/out.wav
"

echo "🎧 Checking output file..."
docker exec -it $CID bash -c "ls -lh /app/out.wav || true"

echo "🌐 Testing API endpoint..."
curl "http://localhost:5005/tts?text=hello from docker"

echo "✅ DONE"
