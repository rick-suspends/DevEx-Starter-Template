# Stage 1: Build Stage (Installs dependencies efficiently)
# Uses a Python-slim image for a smaller footprint
FROM python:3.11-slim as builder

# Set environment variables for the application
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

# Set the working directory inside the container
WORKDIR /app

# Install dependencies (using the requirements.txt you created)
# Copy only the requirements file first to leverage Docker caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt


# -------------------------------------------------------------
# Stage 2: Final Runtime Image (Minimal and Secure)
# -------------------------------------------------------------
FROM python:3.11-slim

# Set the working directory
WORKDIR /app

# Copy the installed dependencies from the builder stage
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Copy the application source code (your FastAPI and Typer files)
# Assuming your source code is in the /src directory
COPY src /app/src

# Create a non-root user for security (best practice for Kubernetes)
RUN useradd --no-create-home appuser
USER appuser

# Expose the port FastAPI listens on (default is 8000)
EXPOSE 8000

# Command to run the application using Uvicorn
# The command targets the 'app' FastAPI instance inside the 'src.api' module
CMD ["python", "-m", "uvicorn", "src.api:app", "--host", "0.0.0.0", "--port", "8000"]

# Set Timezone

FROM ubuntu:latest

# Use ARG for build-time variables
ARG TZ=America/Denver
ENV TZ=${TZ}

# Install tzdata and configure the system
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get clean

# Crontab

FROM ubuntu:latest

# 1. Install cron
RUN apt-get update && apt-get install -y cron

# 2. Copy the crontab file to the cron.d directory
COPY crontab /etc/cron.d/my-cron-job

# 3. Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/my-cron-job

# 4. Apply the cron job
RUN crontab /etc/cron.d/my-cron-job

# 5. Create the log file to be able to run tail
RUN touch /var/log/cron.log

# 6. Run the command on container startup
# Using 'cron && tail -f' keeps the container running
CMD cron && tail -f /var/log/cron.log
