# 🛠️ DevEx Project Starter Template

This repository serves as a **production-ready, basic starting point (template)** for building any Developer Experience (DevEx) focused project, API, or service.

It provides a pre-configured, modular foundation that demonstrates best practices for **containerization, CI/CD readiness, and cloud deployment**, allowing your team to focus immediately on the core business logic.

The included **Jekyll Docs Validator Tool Suite** is a functional example of how a critical DevEx project—ensuring documentation quality—can be built and deployed using this template.

-----

## ✨ Template Features & DevEx Best Practices

This template provides the essential architectural elements required for modern DevEx tools, all pre-configured:

| Component | Purpose & DevEx Benefit | Status in this Repo |
| :--- | :--- | :--- |
| **Python API Core** | **FastAPI** framework provides high-performance, automatic API documentation (Swagger/ReDoc), and robust structure. | ✅ **Pre-configured** |
| **Containerization** | Optimized **Dockerfiles** and **`docker-compose`** for consistent environments across development and production. | ✅ **Ready-to-use** |
| **Cloud Hosting** | Deployment configuration optimized for cost-effective, high-availability platforms like **Lightsail Container Service**. | ✅ **Proven Stability** |
| **Documentation** | Clear, comprehensive `README.md` structure and logging practices to ensure quick onboarding for contributors. | ✅ **Starter Content** |

-----

## 📦 Included Example: Jekyll Docs Validator Tool Suite

The functional code within this repository provides a working example of a DevEx tool to help you get started:

The **Jekyll Docs Validator API & CLI** is designed to:

  * **Enforce Quality:** Automate checks for documentation integrity.
  * **Reduce Friction:** Quickly validate Markdown, link health, and asset coherence in a GitHub Actions workflow.
  * **Improve DX:** Provide immediate, clear feedback to developers submitting documentation changes.

-----

## 🛠️ Getting Started (Using the Template)

To start a new DevEx project using this foundation:

1.  **Clone the Repository:**
    ```bash
    git clone git@github.com:rick-suspends/DevEx-Docs-Validator new-devex-project
    cd new-devex-project
    ```
2.  **Modify Core Logic:**
      * Edit the Python files in the `/src` directory to implement your new tool's logic.
      * Update the `requirements.txt` file for any new dependencies.
3.  **Rename/Rebrand:** Update the image name in the `Dockerfile` and `docker-compose.yaml` files, and rebrand the `README.md`.
4.  **Build and Test:**
    ```bash
    docker-compose up --build
    ```
    Your new service will be available at `http://localhost:8000`.

-----

## ☁️ Deployment Reference

This table provides the live access point for the example validator service, demonstrating a successful deployment from this template:

| Environment | Service | Access URL |
| :--- | :--- | :--- |
| **Production** | AWS Lightsail Container Service | `https://container-service-1.gqceswqwzkchr.us-west-2.cs.amazonlightsail.com` |