#!/bin/bash

# Define the repository
REPO_URL="https://github.com/bochamaakram/backendbot.git"

# Default destination
DEFAULT_DEST="$PWD/.backend-blueprints"

echo "🚀 Welcome to the Standard Project Instructions Installer"
echo ""

# Ask for destination directory
read -p "Enter destination directory [$DEFAULT_DEST]: " USER_DEST < /dev/tty
DEST_DIR="${USER_DEST:-$DEFAULT_DEST}"

echo ""
echo "This will install the standard project instructions (blueprints) into:"
echo "📁 $DEST_DIR/schema"
echo ""

read -p "Do you want to proceed? [Y/n] " confirm < /dev/tty
if [[ "$confirm" =~ ^[nN] ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo "🚀 Installing Standard Project Instructions..."

# 1. Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Error: git is not installed."
    exit 1
fi

# 2. Clone to temporary directory and move docs
echo "Fetching latest blueprints..."
TEMP_DIR=$(mktemp -d)

if git clone --depth 1 "$REPO_URL" "$TEMP_DIR" &> /dev/null; then
    mkdir -p "$DEST_DIR"
    # Remove old schema if it exists and copy new one
    rm -rf "$DEST_DIR/schema"
    cp -r "$TEMP_DIR/schema" "$DEST_DIR/"
    
    # Cleanup temp
    rm -rf "$TEMP_DIR"
    
    echo "✅ Setup complete! The blueprints are available in $DEST_DIR/schema"
else
    echo "❌ Error: Failed to clone repository."
    rm -rf "$TEMP_DIR"
    exit 1
fi