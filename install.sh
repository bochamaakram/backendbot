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

# 2. Clone or Update the files
if [ -d "$DEST_DIR" ]; then
    echo "Updating existing files..."
    cd "$DEST_DIR" && git pull
else
    echo "Cloning repository to $DEST_DIR..."
    git clone "$REPO_URL" "$DEST_DIR"
fi

chmod +x "$DEST_DIR/init-script.sh"

echo "✅ Setup complete! You can now use the project instructions."