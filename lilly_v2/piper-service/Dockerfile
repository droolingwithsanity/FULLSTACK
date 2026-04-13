FROM ubuntu:22.04

RUN apt update && apt install -y \
    python3 python3-pip \
    ffmpeg wget

WORKDIR /app

# copy everything cleanly
COPY piper /app/piper
COPY voices /app/voices
COPY server.py /app/server.py

RUN chmod +x /app/piper/piper

RUN pip3 install fastapi uvicorn

EXPOSE 5005

CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "5005"]
