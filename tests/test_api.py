import os
import tempfile
import pytest
from fastapi.testclient import TestClient
from src.api import app, find_orphaned_files

client = TestClient(app)


# --- /status ---

def test_status_returns_200():
    response = client.get("/status")
    assert response.status_code == 200

def test_status_shape():
    data = client.get("/status").json()
    assert data["status"] == "ok"
    assert "service_name" in data
    assert "version" in data
    assert "timestamp" in data


# --- /info ---

def test_info_returns_200():
    response = client.get("/info")
    assert response.status_code == 200

def test_info_shape():
    data = client.get("/info").json()
    assert "docs_system" in data
    assert "cli_library" in data
    assert isinstance(data["devops_tools"], list)
    assert len(data["devops_tools"]) > 0


# --- /check-orphans ---

def test_check_orphans_returns_200():
    response = client.get("/check-orphans")
    assert response.status_code == 200

def test_check_orphans_shape():
    data = client.get("/check-orphans").json()
    assert "orphaned_files" in data
    assert "count" in data
    assert isinstance(data["orphaned_files"], list)
    assert data["count"] == len(data["orphaned_files"])


# --- find_orphaned_files ---

def test_find_orphaned_files_empty_dir():
    with tempfile.TemporaryDirectory() as tmpdir:
        assert find_orphaned_files(tmpdir) == []

def test_find_orphaned_files_nonexistent_dir():
    assert find_orphaned_files("/nonexistent/path") == []

def test_find_orphaned_files_detects_orphan():
    with tempfile.TemporaryDirectory() as tmpdir:
        # index.html links to linked.html but not orphan.html
        index = os.path.join(tmpdir, "index.html")
        linked = os.path.join(tmpdir, "linked.html")
        orphan = os.path.join(tmpdir, "orphan.html")

        with open(index, "w") as f:
            f.write('<a href="linked.html">linked</a>')
        with open(linked, "w") as f:
            f.write("<p>linked page</p>")
        with open(orphan, "w") as f:
            f.write("<p>orphaned page</p>")

        result = find_orphaned_files(tmpdir)
        assert "orphan.html" in result
        assert "linked.html" not in result

def test_find_orphaned_files_no_orphans():
    with tempfile.TemporaryDirectory() as tmpdir:
        index = os.path.join(tmpdir, "index.html")
        linked = os.path.join(tmpdir, "linked.html")

        with open(index, "w") as f:
            f.write('<a href="linked.html">linked</a>')
        with open(linked, "w") as f:
            f.write("<p>linked page</p>")

        result = find_orphaned_files(tmpdir)
        assert result == []
