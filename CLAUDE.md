# CLAUDE.md — DevEx Starter Template

## Project purpose

This repo is a production-ready starter template for Developer Experience (DevEx) tools. The working example included is a **Jekyll Docs Validator**: a FastAPI service and Typer CLI that automate documentation quality checks.

Work here focuses on maintaining and extending the validator example within this repo.

---

## Architecture

| Path | Role |
|------|------|
| `src/api.py` | FastAPI app — health, info, and orphan-detection endpoints |
| `src/cli.py` | Typer CLI (`docstool`) — URL reachability checker |
| `docs/` | Jekyll documentation site (source + `_site` build output) |
| `Dockerfile` | Multi-stage Python build; runs `cron` + `uvicorn` together |
| `crontab` | Weekday cron jobs (6:45am, 12:45pm) — runs `bin/cron-script.sh` |
| `devex-deployment.yaml` | Kubernetes Deployment manifest (targets AWS Lightsail) |
| `devex-service.yaml` | Kubernetes Service manifest (NodePort) |
| `bin/` | Helper scripts — **do not modify** |
| `env/install-env.sh` | Local environment setup script |

---

## Key commands

**Run the API locally (no Docker):**
```bash
pip install -r requirements.txt
python -m uvicorn src.api:app --reload --host 0.0.0.0 --port 8000
```

**Build and run with Docker:**
```bash
docker build -t devex-docs-validator .
docker run -p 8000:8000 devex-docs-validator
```

**Run the CLI:**
```bash
python src/cli.py check-url https://example.com
```

**API endpoints:**
- `GET /status` — liveness/readiness health check
- `GET /info` — service metadata
- `GET /check-orphans` — scans `docs/_site` for HTML files with no incoming links
- `GET /docs` — Swagger UI (auto-generated)

---

## Conventions

- **FastAPI + Pydantic v2:** All request/response shapes are Pydantic models. Keep endpoints tagged and documented for Swagger.
- **Validation logic lives in `src/`** — keep API and CLI thin; put logic in shared helpers.
- **Kubernetes probes** use `/status` — don't change its response shape or path.
- **Docker image name:** `richardmallery/devex-docs-validator:latest` — update when forking.

---

## Off-limits

- `bin/cron-script.sh` — environment-specific, do not modify.

---

## TODO

- [x] Add `pytest` tests under a `tests/` directory (pytest is already in `requirements.txt`).
- [ ] Re-enable and audit GitHub Actions workflows in `.github/disabled-workflows/`.
- [x] Add `docstool check-orphans` CLI command mirroring the `/check-orphans` API endpoint.
- `docs/topics/test.md` — intentionally empty, exists to provide a real orphan hit for the `check-orphans` tests.
