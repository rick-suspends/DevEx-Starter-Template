---
layout: page
title: Welcome to the DevEx Starter Template docs 
permalink: /
---

# {{ page.title }}

This project has three main sections: 
- **Jekyll-based documentation content** &mdash; Markdown -> Jekyll -> HTML/JS/CSS -> GitHub Pages
- **Python tools** &mdash; Validate the Markdown, links, and assets of the documentation content
- **CI/CD flow** &mdash; GitHub Action workflows to run the Python tools before rebuilding and updating the Docker image, and before pushing doc changes to GitHub Pages.

## GitHub repository

Since this repository is a **DevEx Starter Template**, the first step is to create your own independent copy by forking the repository. 

1. Create a server-side fork (web)

    1.  Navigate to the [DevEx Starter Template GitHub page](https://github.com/rick-suspends/DevEx-Starter-Template).

    2.  Click the **Fork** button to create a copy of the repository under your personal account.

2. Clone your fork (command line)

    After the fork is complete, clone **your new copy** to your local machine. This is the sole remote (`origin`) for your project going forward.

    ```bash
    # Replace YOUR_USERNAME and YOUR_REPO with your new fork details
    git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
    cd YOUR_REPO
    ```

    **Your project is now initialized.** All changes, pushes, and branches are managed within your new repository.

## Jekyll-based doc content

Jekyll is a static site generator that transforms your Markdown content into a complete website. In this project, Jekyll configuration files are located in the `/docs` directory.

This section covers the Jekyll-based documentation content, including Markdown, Jekyll, HTML/JS/CSS, and GitHub Pages.

### Markdown

Use Markdown to create the content for your documentation. It is a lightweight markup language with plain text formatting syntax. In this project, Markdown files are located in the `/docs/topics` directory.

You should pick a style guide for your Markdown content to ensure consistency. This project follows the [Google Developer Documentation Style Guide](https://developers.google.com/style/) style guide for technical documentation.

### Jekyll

Jekyll processes the Markdown files and applies templates to generate a static website. The Jekyll configuration file (`_config.yml`) and layout files are located in the `/docs` directory.

You need to install Jekyll and its dependencies to build the site locally. Follow the [Jekyll installation guide](https://jekyllrb.com/docs/installation/) for your operating system.

For full details on how the Jekyll system is set up in this project, see [Jekyll system](jekyll-system.html).

### HTML/JS/CSS

Format your static website pages with JavaScript and CSS to enhance the user experience of your documentation site.

These files are in the `/docs/assets/css` and `/docs/assets/js` directories.

### GitHub Pages

GitHub Pages hosts your Jekyll-generated static site directly from your GitHub repository. The site is automatically built and deployed whenever you push changes to the repository.

To enable GitHub Pages for your repository, go to the repository **Settings**, navigate to the **Pages** section, and select the source branch and folder (usually `main` branch and `/docs` folder).

Optionally, you can configure a custom domain for your GitHub Pages site in the same **Pages** section of the repository **Settings**.

## Python tools

This project includes Python tools to validate the Markdown, links, and assets of the documentation content.

### FastAPI and Swagger docs

The FastAPI application provides automatic API documentation using Swagger and ReDoc. 

The FastAPI app is located in the `/src/api.py` file. 

You can see an example of Swagger docs for the deployed instance of this project at this [Lightsail container](https://container-service-1.gqceswqwzkchr.us-west-2.cs.amazonlightsail.com/docs).

### Typer CLI

The Typer command-line interface (CLI) allows you to run the validation tools from the command line.

The Typer CLI is located in the `/src/cli.py` file.

To run the CLI, navigate to the project root directory and use the following command:

```bash
python -m src.cli <command> [options]
```

## CI/CD flow

When you push changes to the repository, GitHub Actions workflows are triggered to run the Python validation tools before rebuilding and updating the Docker image and before updating GitHub Pages with doc changes.

### GitHub actions

GitHub Actions workflows are defined in the `.github/workflows` directory.

The **DevEx Starter Template** includes the following workflows:

- **Check Links** &mdash; This workflow runs `htmlproofer` to check for broken links in the generated site whenever changes are pushed to the `main` branch.

- **Generate PDF** &mdash; This workflow generates a PDF version of the documentation site using `wkhtmltopdf` whenever changes are pushed to the `main` branch. 

  For example, to see the PDF for this documentation, check out the [PDF file in the GitHub Pages site](https://rick-suspends.github.io/DevEx-Starter-Template/pdfs/assembled.pdf).

- Others coming soon...

### Docker

The Dockerfile and Docker Hub repository are used to build and store the Docker image for your project. The Dockerfile is located in the root of the repository, and the Docker Hub repository should be created under your Docker Hub account.

### Deploy image

You can deploy your image to a cloud service like AWS Lightsail Container Service, AWS ECS, or any other container orchestration platform.