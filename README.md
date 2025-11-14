# 🛠️ DevEx Starter Template

This repository serves as a **production-ready, basic starting point (template)** for building any Developer Experience (DevEx) focused project, API, or service.

It provides a pre-configured, modular foundation that demonstrates best practices for **containerization, CI/CD readiness, and cloud deployment**, allowing your team to focus immediately on the core business logic.

The included **Jekyll Docs Tool Suite** is a functional example of a DevEx documentation system.

-----

## ✨ Template Features & DevEx Best Practices

This template provides pre-configured architectural elements required for DevEx tools:

| Component | Purpose & DevEx Benefit | Status in this Repo |
| :--- | :--- | :--- |
| **Python API Core** | **FastAPI** framework provides high-performance, automatic API documentation (Swagger/ReDoc), and robust structure. | ✅ **Pre-configured** |
| **Containerization** | Optimized **Dockerfiles** and **`docker-compose`** for consistent environments across development and production. | ✅ **Ready-to-use** |
| **Cloud Hosting** | Deployment configuration optimized for cost-effective, high-availability platforms like **Lightsail Container Service** or a machine hosting a **Kubernetes cluster**. | ✅ **Proven Stability** |
| **Documentation** | Clear, comprehensive `README.md` structure and logging practices to ensure quick onboarding for contributors. | ✅ **Starter Content** |

-----

## 📦 Included Example: Jekyll Docs Validator Tool Suite

The functional code within this repository provides a working example of a DevEx tool to help you get started:

The **Jekyll Docs Validator API & CLI** is designed to:

  * **Enforce Quality:** Automate checks for documentation integrity.
  * **Reduce Friction:** Quickly validate Markdown, link health, and asset coherence in a GitHub Actions workflow.
  * **Improve DX:** Provide immediate, clear feedback to developers submitting documentation changes.

### Access Jekyll Example

In the `/docs` directory is a functional Jekyll system with all the elements you need to build out your own Jekyll project.

See the Jekyll out put at [Jekyll Docs Validator Docs](https://rick-suspends.github.io/DevEx-Docs-Validator/).

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
5. **Update documentation**
    Follow the full documentation flow in the Jekyll example to create, generate, and publish project documentation. See [DevEx Starter Template Docs](https://rick-suspends.github.io/DevEx-Docs-Validator/). 

-----

## ☁️ Deployment Reference

This table provides the live access point for the example validator service, demonstrating a successful deployment from this template:

| Environment | Service | Access URL |
| :--- | :--- | :--- |
| **Production** | AWS Lightsail Container Service | 
   Get Status: `https://container-service-1.gqceswqwzkchr.us-west-2.cs.amazonlightsail.com\status`<br>
   Get Info: `https://container-service-1.gqceswqwzkchr.us-west-2.cs.amazonlightsail.com\info`<br>
   View docs: `https://container-service-1.gqceswqwzkchr.us-west-2.cs.amazonlightsail.com\docs`
|