# --- Stage 1: Builder ---
FROM python:3.11-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- Stage 2: Final Image ---
FROM python:3.11-slim

# 1. Set Environment Variables
ENV TZ=America/Denver
ENV PYTHONUNBUFFERED=1
WORKDIR /app

# 2. Install System Dependencies (Cron + TZData)
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cron tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get clean

# 3. Copy Python dependencies from builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY src /app/src

# 4. Configure Cron
COPY crontab /etc/cron.d/my-cron-job
RUN chmod 0644 /etc/cron.d/my-cron-job && \
    crontab /etc/cron.d/my-cron-job && \
    touch /var/log/cron.log

# 5. Set Permissions
# Note: Cron usually needs to run as root. 
# If you use 'USER appuser', cron might fail to access /etc/cron.d
RUN useradd --no-create-home appuser

# 6. Start BOTH Cron and Python
# We start cron in the background (&) and uvicorn in the foreground
CMD cron && python -m uvicorn src.api:app --host 0.0.0.0 --port 8000
