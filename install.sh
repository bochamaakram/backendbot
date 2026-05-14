#!/bin/bash

# Define the repository and destination
REPO_URL="https://github.com/bochamaakram/backendbot.git"
DEST_DIR="$PWD/.backend-blueprints" # this will be copied to your current folder

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
    # Remove old docs if they exist and copy new ones
    rm -rf "$DEST_DIR/docs"
    cp -r "$TEMP_DIR/docs" "$DEST_DIR/"
    
    # Cleanup temp
    rm -rf "$TEMP_DIR"
    
    echo "✅ Setup complete! The blueprints are available in $DEST_DIR/docs/schema"
else
    echo "❌ Error: Failed to clone repository."
    rm -rf "$TEMP_DIR"
    exit 1
fi