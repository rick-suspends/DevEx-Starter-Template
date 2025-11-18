#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "--- Running environment setup script ---"

# 1. Update package lists
echo "Updating apt package lists..."
sudo apt update

# 2. Install core system dependencies (check if already installed for idempotence)
echo "Installing core system dependencies..."
REQUIRED_APT_PACKAGES=(
    git
    curl
    wget
    python3
    python3-pip
    python3-venv     # <--- ADD THIS: Required for python3 -m venv
    build-essential
    ruby-full
    zlib1g-dev
    fontconfig
    libfreetype6
    libx11-6
    libxext6
    libxrender1
    xfonts-base
    xfonts-75dpi
    xvfb
)

for pkg in "${REQUIRED_APT_PACKAGES[@]}"; do
    if ! dpkg -s "$pkg" &> /dev/null; then
        echo "Installing $pkg..."
        sudo apt install -y "$pkg"
    else
        echo "$pkg is already installed."
    fi
done

# Special handling for libssl1.1
if ! dpkg -s libssl1.1 &> /dev/null; then
    echo "Attempting to install libssl1.1 from Ubuntu archive for wkhtmltopdf..."
    wget -q http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb -O /tmp/libssl1.1.deb || echo "libssl1.1 download failed, continuing..."
    sudo dpkg -i /tmp/libssl1.1.deb || sudo apt install -f -y # Install, then fix broken dependencies
    rm -f /tmp/libssl1.1.deb # Clean up
else
    echo "libssl1.1 is already installed."
fi

# 3. Install wkhtmltopdf .deb package if not already present
if ! command -v wkhtmltopdf &> /dev/null; then
    echo "Installing wkhtmltopdf 0.12.6 bionic build (if not already installed)..."
    WKHTMLTOPDF_URL="https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6-1/wkhtmltox_0.12.6-1.bionic_amd64.deb"
    wget -q ${WKHTMLTOPDF_URL} -O /tmp/wkhtmltox.deb
    sudo dpkg -i /tmp/wkhtmltox.deb || sudo apt install -f -y # Install, then fix broken dependencies
    rm -f /tmp/wkhtmltox.deb # Clean up
    echo "wkhtmltopdf --version: $(wkhtmltopdf --version)"
else
    echo "wkhtmltopdf is already installed."
fi


# --- 4. Python Virtual Environment Setup and Dependencies ---
echo "Setting up Python virtual environment and installing dependencies..."
REPO_ROOT=$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.. # Navigate up from env/ to repo root
VENV_DIR="$REPO_ROOT/.venv" # Virtual environment directory

# Create virtual environment if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating virtual environment at $VENV_DIR"
    python3 -m venv "$VENV_DIR"
else
    echo "Virtual environment already exists at $VENV_DIR"
fi

# Activate the virtual environment for this script's Python operations
source "$VENV_DIR/bin/activate"

# Install Python dependencies from requirements.txt
if [ -f "$REPO_ROOT/requirements.txt" ]; then
    echo "Installing Python packages into virtual environment..."
    pip install -r "$REPO_ROOT/requirements.txt"
else
    echo "Warning: requirements.txt not found at $REPO_ROOT/requirements.txt"
fi

# Deactivate the virtual environment (important for script to not leave it active globally)
# The .customrc will handle activation for interactive shells.
deactivate || true # 'deactivate' might fail if not fully active, so '|| true'

# 5. Install Ruby gems
echo "Installing Ruby gems with Bundler..."
if command -v bundle &> /dev/null; then
    if [ -f "$REPO_ROOT/Gemfile" ]; then
        if ! gem list -i bundler &> /dev/null; then
            sudo gem install bundler
        fi
        cd "$REPO_ROOT" && bundle install --path vendor/bundle
        cd - > /dev/null
    else
        echo "Warning: Gemfile not found at $REPO_ROOT/Gemfile"
    fi
else
    echo "Bundler not found. Please install with 'sudo gem install bundler' if needed for Ruby projects."
fi


echo "--- Environment setup script finished ---"
