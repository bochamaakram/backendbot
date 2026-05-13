#!/usr/bin/env bash

# ==============================================================================
# BackendBot — Global Installation Script
# This installer links the CLI to your local system's PATH.
# ==============================================================================

# Get absolute path of repository root
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Elegant Terminal Palette
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Premium Icons
CHECK_MARK="🟢"
ERROR_X="🔴"
SPARKLES="✨"
ARROW="⚡"

echo -e "${PURPLE}${BOLD}┌────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}${BOLD}│${NC}  ${SPARKLES}  ${BOLD}BackendBot — Installation Assistant${NC}           ${PURPLE}${BOLD}│${NC}"
echo -e "${PURPLE}${BOLD}└────────────────────────────────────────────────────────┘${NC}"

# 1. Make the source script executable
echo -e "${ARROW} Configuring executable permissions..."
chmod +x "$REPO_ROOT/bin/backendbot"

# 2. Ensure target bin directory exists
mkdir -p "$HOME/.local/bin"

# 3. Create absolute symlink (remove old file/symlink if present)
echo -e "${ARROW} Creating global terminal shortcut..."
rm -f "$HOME/.local/bin/backendbot"
ln -s "$REPO_ROOT/bin/backendbot" "$HOME/.local/bin/backendbot"

if [ $? -eq 0 ]; then
    echo -e "\n${CHECK_MARK} ${GREEN}${BOLD}Success! BackendBot CLI is installed on your machine!${NC}"
    echo -e "Symlink created:"
    echo -e "  ${BLUE}$HOME/.local/bin/backendbot${NC} -> ${BLUE}$REPO_ROOT/bin/backendbot${NC}"
else
    echo -e "\n${ERROR_X} ${RED}Error: Failed to create symlink at $HOME/.local/bin/backendbot${NC}"
    exit 1
fi

# 4. PATH Check & Shell Hinting
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "\n${YELLOW}⚠️  Warning: $HOME/.local/bin is not in your current shell's PATH.${NC}"
    echo -e "To use the 'backendbot' command from anywhere, add this line to your shell profile"
    echo -e "such as ${BOLD}~/.bashrc${NC} or ${BOLD}~/.zshrc${NC}:"
    echo -e "\n  ${CYAN}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}\n"
    echo -e "Then reload your shell with: ${BOLD}source ~/.zshrc${NC} (or bashrc)"
else
    echo -e "\n${SPARKLES} ${GREEN}${BOLD}Ready to go!${NC} You can now run ${BOLD}${CYAN}backendbot${NC} inside any of your project directories."
fi
