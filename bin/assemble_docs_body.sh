#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Script to assemble main content from Jekyll's _site/*.html files
# into a single, valid HTML file, then convert to PDF using wkhtmltopdf.
# This version ensures:
# 1. Only the content within <main class="content"> tags is extracted.
# 2. The intermediate assembled HTML is created ONLY in the 'bin' directory.
# 3. A temporary Python HTTP server serves the Jekyll _site directory (for assets).
# 4. xvfb-run provides a virtual display environment for wkhtmltopdf.
# 5. wkhtmltopdf reads the intermediate HTML locally, but fetches assets via the HTTP server (using <base href>).
# 6. The final PDF is output to the 'docs/pdfs' directory.
# 7. No extraneous header or description is added to the assembled content.

# --- Configuration ---
# Path to the script's own directory (e.g., 'bin')
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Project root directory (one level up from script_dir)
PROJECT_ROOT=$(realpath "$SCRIPT_DIR/..")

# Path to the Jekyll _site directory, relative to PROJECT_ROOT
DOCS_SITE_RELATIVE_PATH="docs/_site_deploy"
DOCS_SITE_DIR="$PROJECT_ROOT/$DOCS_SITE_RELATIVE_PATH"

# New output directory for PDFs, relative to PROJECT_ROOT
PDF_OUTPUT_DIR="$PROJECT_ROOT/docs/pdfs"

# Intermediate HTML filename (will be created ONLY in SCRIPT_DIR - the bin directory)
INTERMEDIATE_HTML_FILE="assembled_docs_body.html"
INTERMEDIATE_HTML_PATH="$SCRIPT_DIR/$INTERMEDIATE_HTML_FILE"

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

echo "Extracting content only from <main class=\"content\"> tags in HTML files within $DOCS_SITE_DIR..."
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
  echo "WARNING: No main content was extracted. The resulting PDF might be empty or contain only boilerplate." >&2
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
    <div class="combined-content">
$(echo -e "$ALL_BODY_CONTENT")
    </div>
</body>
</html>
EOF

echo "Intermediate HTML created: $INTERMEDIATE_HTML_PATH"

# --- Start a temporary Python HTTP server ---
# We start the server directly in the DOCS_SITE_DIR.
# This makes Jekyll _site assets (like /assets/css and /assets/images) accessible
# at http://localhost:8000/assets/...
echo "Starting temporary Python HTTP server in $DOCS_SITE_DIR on port $HTTP_SERVER_PORT..."
(cd "$DOCS_SITE_DIR" && python3 -m http.server "$HTTP_SERVER_PORT" > "$SCRIPT_DIR/http_server_stdout.log" 2> "$SCRIPT_DIR/http_server_stderr.log" &)

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
# wkhtmltopdf reads the intermediate HTML file directly from the local filesystem ($INTERMEDIATE_HTML_PATH),
# but the <base href> in that HTML ($HTTP_SERVER_PORT) tells it where to fetch assets.
echo "Converting via wkhtmltopdf with xvfb-run from $INTERMEDIATE_HTML_PATH to $OUTPUT_PDF_FILE..."
xvfb-run --auto-servernum --server-args="-screen 0 1024x768x24" \
  /usr/bin/wkhtmltopdf "$INTERMEDIATE_HTML_PATH" "$OUTPUT_PDF_FILE"


echo "Attempting PDF conversion with xvfb-run and wkhtmltopdf..."

# Example of how your script might then check and exit:
if [ -f "$OUTPUT_PDF_FILE" ]; then
    echo "PDF generated successfully: $OUTPUT_PDF_FILE"
    exit 0 # Your script should now explicitly exit 0 on success
else
    echo "ERROR: PDF was not generated at $OUTPUT_PDF_FILE" >&2
    exit 1 # Your script should now explicitly exit 1 on failure
fi

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
