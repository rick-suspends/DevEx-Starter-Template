#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Script to assemble body content from Jekyll's _site/*.html files
# into a single, valid HTML file, then convert to PDF using wkhtmltopdf.
# This version uses:
# 1. A temporary Python HTTP server to serve the Jekyll _site directory
#    (essential for wkhtmltopdf to find assets like CSS and images via HTTP).
# 2. xvfb-run to provide a virtual display environment (preventing crashes
#    in headless environments like your VM).
# 3. Places the intermediate HTML in the 'bin' directory.
# 4. wkhtmltopdf directly reads the intermediate HTML locally, but uses the
#    HTTP server via <base href> for assets.

# --- Configuration ---
# Path to the script's own directory (e.g., 'bin')
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Project root directory (one level up from script_dir)
PROJECT_ROOT=$(realpath "$SCRIPT_DIR/..")

# Path to the Jekyll _site directory, relative to PROJECT_ROOT
DOCS_SITE_RELATIVE_PATH="docs/_site"
DOCS_SITE_DIR="$PROJECT_ROOT/$DOCS_SITE_RELATIVE_PATH"

# New output directory for PDFs, relative to PROJECT_ROOT
PDF_OUTPUT_DIR="$PROJECT_ROOT/docs/pdfs"

# Intermediate HTML filename (will be created in SCRIPT_DIR)
INTERMEDIATE_HTML_FILE="assembled_docs_body.html"
INTERMEDIATE_HTML_PATH="$SCRIPT_DIR/$INTERMEDIATE_HTML_FILE" # CORRECTED: In bin dir

# Final Output PDF filename (will be created in PDF_OUTPUT_DIR)
OUTPUT_PDF_FILE="$PDF_OUTPUT_DIR/assembled.pdf"

# Port for the temporary Python HTTP server
HTTP_SERVER_PORT=8000

# --- Main Logic ---

echo "Starting document assembly and PDF conversion..."

# Ensure the PDF output directory exists
mkdir -p "$PDF_OUTPUT_DIR"

# Check if the docs site directory exists
if [ ! -d "$DOCS_SITE_DIR" ]; then
  echo "ERROR: Jekyll _site directory not found at: $DOCS_SITE_DIR" >&2
  echo "Please ensure you run 'jekyll build' or 'jekyll serve' first." >&2
  exit 1
fi

# Initialize an empty string to hold all extracted body content
ALL_BODY_CONTENT=""

echo "Extracting main content from HTML files in $DOCS_SITE_DIR..."
for html_file in "$DOCS_SITE_DIR"/*.html; do
  if [ -f "$html_file" ]; then
    # Extract content between <main class="content"> and </main>
    # This specifically targets the main article content, excluding headers, footers, sidebars.
    body_content=$(awk '/<main class="content"[^>]*>/, /<\/main>/ {
                           # Only print lines that are NOT the opening or closing tag themselves
                           if (! /<main class="content"[^>]*>/ && ! /<\/main>/) {
                               print $0
                           }
                       }' "$html_file")

    if [ -n "$body_content" ]; then
        ALL_BODY_CONTENT+="\n<div class=\"file-separator\" data-source=\"$(basename "$html_file")\"></div>\n"
        ALL_BODY_CONTENT+="$body_content\n"
    fi
  fi
done

if [ -z "$ALL_BODY_CONTENT" ]; then
  echo "WARNING: No body content was extracted. The resulting PDF might be empty or contain only boilerplate." >&2
fi

# Create the intermediate HTML file directly in the SCRIPT_DIR (bin directory)
cat <<EOF > "$INTERMEDIATE_HTML_PATH"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assembled Documentation Body</title>
    <style>
        body { font-family: sans-serif; line-height: 1.6; margin: 20px; }
        h1, h2, h3 { color: #333; }
        .file-separator {
            border-top: 2px dashed #ccc;
            margin: 40px 0;
            padding-top: 20px;
            font-size: 0.9em;
            color: #666;
            text-align: center;
        }
        .file-separator::before {
            content: attr(data-source);
            display: block;
            margin-bottom: 10px;
        }
        .combined-content {
            margin-top: 30px;
        }
    </style>
    <base href="http://localhost:$HTTP_SERVER_PORT/" />
</head>
<body>
    <h1>Assembled Documentation Content</h1>
    <p>This file contains the combined content from your Jekyll pages, excluding site headers/footers/sidebars.</p>
    <div class="combined-content">
$(echo -e "$ALL_BODY_CONTENT")
    </div>
</body>
</html>
EOF

echo "Intermediate HTML created: $INTERMEDIATE_HTML_PATH"

# --- Start a temporary Python HTTP server ---
# We now start the server directly in the DOCS_SITE_DIR.
# This makes Jekyll _site assets accessible at http://localhost:8000/assets/...
echo "Starting temporary Python HTTP server in $DOCS_SITE_DIR on port $HTTP_SERVER_PORT..."
(cd "$DOCS_SITE_DIR" && python3 -m http.server "$HTTP_SERVER_PORT" > "$SCRIPT_DIR/http_server_stdout.log" 2> "$SCRIPT_DIR/http_server_stderr.log" &) # <--- Corrected: cd into DOCS_SITE_DIR

# Wait a bit longer for the server to spin up
sleep 3

# Robustly get PID using lsof
PYTHON_PID=$(lsof -t -i :"$HTTP_SERVER_PORT" | head -n 1)

if [ -z "$PYTHON_PID" ]; then
  echo "ERROR: Python HTTP server failed to start or PID could not be found." >&2
  echo "Check '$SCRIPT_DIR/http_server_stderr.log' for details." >&2
  exit 1
fi
echo "Python HTTP server confirmed running on port $HTTP_SERVER_PORT (PID: $PYTHON_PID)."

# --- Convert HTML to PDF using wkhtmltopdf via local file path and xvfb-run ---
# wkhtmltopdf reads the intermediate HTML file directly from the local filesystem,
# but the <base href> in that HTML tells it to fetch assets from the HTTP server.
echo "Converting via wkhtmltopdf with xvfb-run from $INTERMEDIATE_HTML_PATH to $OUTPUT_PDF_FILE..."
xvfb-run --auto-servernum --server-args="-screen 0 1024x768x24" \
  /usr/bin/wkhtmltopdf "$INTERMEDIATE_HTML_PATH" "$OUTPUT_PDF_FILE" # <--- CORRECTED: Use local path for HTML input

# --- Stop the Python HTTP server ---
echo "Stopping Python HTTP server (PID: $PYTHON_PID)..."
if [ -n "$PYTHON_PID" ]; then
  kill "$PYTHON_PID"
  wait "$PYTHON_PID" 2>/dev/null # Wait for it to exit, suppress "Terminated" message
else
  echo "WARNING: PYTHON_PID was empty, could not explicitly kill the HTTP server process."
fi

echo "PDF conversion complete. Output file: $OUTPUT_PDF_FILE"
# Clean up intermediate files
rm -f "$INTERMEDIATE_HTML_PATH"
rm -f "$SCRIPT_DIR/http_server_stdout.log" "$SCRIPT_DIR/http_server_stderr.log"
echo "Cleaned up intermediate HTML file and server logs."

echo "Script finished."
