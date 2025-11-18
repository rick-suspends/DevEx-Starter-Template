from fastapi import FastAPI
from pydantic import BaseModel
import uvicorn
import os
from datetime import datetime
import re
from pathlib import Path

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

# --- 3. Helper Functions ---

def find_orphaned_files(site_dir):
    """
    Find orphaned HTML files with no incoming links in the site directory.
    
    Args:
        site_dir: Path to the _site directory
        
    Returns:
        List of orphaned file paths
    """
    site_path = Path(site_dir).resolve()
    
    if not site_path.exists():
        return []
    
    # Get all HTML files
    all_files = set()
    for html_file in site_path.rglob("*.html"):
        rel_path = html_file.relative_to(site_path)
        all_files.add(str(rel_path).replace('\\', '/'))
    
    # Track which files are linked to
    linked_files = set()
    
    # Scan all HTML files for links
    for html_file in site_path.rglob("*.html"):
        try:
            with open(html_file, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                
                # Find all href links
                hrefs = re.findall(r'href=["\']([^"\']+)["\']', content)
                
                for href in hrefs:
                    # Skip external links, anchors, and special protocols
                    if href.startswith(('http://', 'https://', 'mailto:', '#', 'javascript:')):
                        continue
                    
                    # Normalize the link
                    target = href.split('#')[0]  # Remove fragments
                    if not target:
                        continue
                    
                    # Handle relative paths
                    if target.startswith('/'):
                        # Absolute path from site root
                        target = target.lstrip('/')
                    else:
                        # Relative path - resolve from current file's directory
                        parent_dir = html_file.parent
                        resolved = (parent_dir / target).resolve()
                        
                        try:
                            target = str(resolved.relative_to(site_path))
                        except ValueError:
                            # Link is outside site directory, skip it
                            continue
                    
                    # Add index.html if pointing to directory
                    if not target.endswith('.html'):
                        target = target.rstrip('/') + '/index.html'
                    
                    target = target.replace('\\', '/')
                    if target in all_files:
                        linked_files.add(target)
        
        except Exception as e:
            print(f"Error reading {html_file}: {e}")
    
    # Entry point (index.html) is never orphaned
    linked_files.add("index.html")
    
    orphaned = sorted(all_files - linked_files)
    return orphaned

# --- 4. Endpoints for DevEx/DevOps ---

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

@app.get("/check-orphans", tags=["Documentation"])
def check_orphans():
    """
    Endpoint to check for orphaned documentation files in ../docs/_site.
    Returns a list of HTML files with no incoming links.
    """
    site_dir = os.path.join(os.path.dirname(__file__), "..", "docs", "_site")
    print(site_dir)
    orphaned = find_orphaned_files(site_dir)
    
    return {
        "orphaned_files": orphaned,
        "count": len(orphaned),
        "site_directory": site_dir
    }


# --- 4. Main Execution Block for Local Running ---

if __name__ == "__main__":
    # Use 0.0.0.0 host for deployment readiness (e.g., in a Docker container)
    print("Starting DevEx Starter Template API on http://0.0.0.0:8000")
    uvicorn.run(app, host="0.0.0.0", port=8000)
