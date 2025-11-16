from fastapi import FastAPI
from pydantic import BaseModel
import uvicorn
import os
from datetime import datetime

# --- 1. Pydantic Models for Data Validation ---

class HealthStatus(BaseModel):
    """Schema for the API /status endpoint."""
    status: str
    service_name: str
    version: str
    timestamp: datetime
    
class ServiceInfo(BaseModel):
    """Schema for the API /info endpoint."""
    docs_system: str
    cli_library: str
    devops_tools: list[str]

# --- 2. FastAPI Application Instance ---

# The 'title' and 'version' appear in the auto-generated Swagger UI (/docs)
app = FastAPI(
    title="DevEx Starter Template API",
    description="A lightweight API for health monitoring and system information.",
    version=os.getenv("VERSION", "1.0.0-dev"),
    contact={
        "name": "Richard Mallery",
        "email": "richard_mallery@yahoo.com",
    },
)

# --- 3. Endpoints for DevEx/DevOps ---

@app.get("/status", response_model=HealthStatus, tags=["DevOps"])
def get_status():
    """
    Health check endpoint used by Kubernetes Liveness/Readiness probes and CI/CD.
    """
    return HealthStatus(
        status="ok",
        service_name="Jekyll Docs Validator API",
        version=app.version,
        timestamp=datetime.now()
    )

@app.get("/info", response_model=ServiceInfo, tags=["Documentation"])
def get_service_info():
    """
    Returns core technical information about the documentation ecosystem.
    Demonstrates Pydantic validation and clear API documentation.
    """
    return ServiceInfo(
        docs_system="Jekyll (Markdown source)",
        cli_library="Typer/Click",
        devops_tools=["GitHub Actions", "Kubernetes", "Docker"]
    )

# --- 4. Main Execution Block for Local Running ---

if __name__ == "__main__":
    # Use 0.0.0.0 host for deployment readiness (e.g., in a Docker container)
    uvicorn.run(app, host="0.0.0.0", port=8000)
