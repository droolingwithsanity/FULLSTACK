#!/bin/bash
echo "Checking LillyOS services..."

curl -s http://localhost:3000/ && echo "✔ Backend OK" || echo "❌ Backend DOWN"
curl -s http://localhost:81/ && echo "✔ Frontend OK" || echo "❌ Frontend DOWN"

echo "Done."