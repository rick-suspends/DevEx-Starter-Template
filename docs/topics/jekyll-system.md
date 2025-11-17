---
layout: page
title: Jekyll system 
permalink: jekyll-system.html
---

# {{ page.title }}

```text
/docs
    ├── _config.yml           # Jekyll configuration file
    ├── _layouts              # Jekyll layout templates
    │     └── page.html       # Layout for documentation pages
    ├── _includes             # Jekyll includes (reusable components)
    ├── _site                 # Generated site (output)
    ├── assets                # CSS, JS, images
    │     ├── css
    │     │    └── main.css   # Main stylesheet
    │     ├── js
    │     │    └── main.js    # Main JavaScript file
    │     └── images          # Image assets
    ├── topics                # Markdown documentation content
    │     └── <your-docs>.md  # Your documentation files
    └── index.md              # Home page content
```

- `_config.yml`: This file contains configuration settings for the Jekyll site, and is also the place to define external resources such as plugins and themes.

  The current configuration defines the minimum settings: where the source files are located and the destination for the generated site. 

- `_layouts`: This directory holds layout templates that define the structure of your documentation pages. The `page.html` layout is the default for rendering individual documentation pages.

- `_includes`: This directory contains reusable components that can be included in multiple pages, such as headers, footers, navigation elements, and boilerplate text. From your content, you include these components with Liquid tags, such as `{% raw %}{% include header.html %}{% endraw %}`.

- `_site`: This is the output directory where Jekyll generates the static site.

- `assets`: This directory contains static assets like CSS, JavaScript, and images used in the documentation.

- `topics`: This directory contains the Markdown files for your documentation content. 

- `index.md`: This file serves as the home page for your documentation site.            

**A note on underscores**: In Jekyll, directories and files that start with an underscore (`_`) are not generated in the static site, but Jekyll uses them for templating and configuration. You can also create your own directories and files that start with an underscore for work in progress or topics you want to remove from the released documentation but keep for future work, or simply store internal notes in them.

For more information on Jekyll's structure and conventions, refer to the [Jekyll documentation](https://jekyllrb.com/docs/structure/).

## Generating and previewing the site 

To run a local Jekyll server for previewing your documentation site, use the following command in your terminal:

```bash
jekyll server
```     

This command starts a local server and watches for changes in your files, allowing you to see updates in real-time as you edit your documentation. By default, the server is accessible at `http://localhost:4000`.

You can also build the site without starting a server using:

```bash
jekyll build
```

This command generates the static site in the `_site` directory without serving it. You can then deploy the contents of the `_site` directory to your web server or hosting service, or as in this DevEx Starter Template examples, doing a `git push` automatically starts a GitHub Action that updates the GitHub Pages site with the updated content. 

