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
