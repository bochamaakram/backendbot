#!/bin/bash

# Define the repository and destination
REPO_URL="https://github.com/bochamaakram/backendbot.git"
DEST_DIR="$PWD/.backend-blueprints" # this will be copied to your current folder

# Color Definitions
NC='\033[0m'
CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
PURPLE='\033[1;35m'
BOLD='\033[1m'

echo -e "${CYAN}🚀 Starting Interactive Blueprint Installer...${NC}"

# 1. Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Error: git is not installed.${NC}"
    exit 1
fi

# 2. Clone to temporary directory
echo -e "${CYAN}Fetching latest blueprints...${NC}"
TEMP_DIR=$(mktemp -d)

if ! git clone --depth 1 "$REPO_URL" "$TEMP_DIR" &> /dev/null; then
    echo -e "${RED}❌ Error: Failed to clone repository.${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Define files under each category
META_FILES=("_overview.md" "_filestructure.md" "_conventions.md")
DATABASE_FILES=("_database.md")
AUTH_FILES=("_authentication.md" "_authorization.md" "_security.md" "_rate_limiting.md")
CORE_FILES=("_modules.md" "_error_handling.md" "_validation.md" "_api_response.md" "_middleware.md" "_logging.md" "_pagination.md" "_file_upload.md" "_audit.md" "_environment.md")
DEVOPS_FILES=("_testing.md" "_deployment.md")
SEO_FILES=("_seo.md" "_geo.md")

# Array of all files
ALL_FILES=("${META_FILES[@]}" "${DATABASE_FILES[@]}" "${AUTH_FILES[@]}" "${CORE_FILES[@]}" "${DEVOPS_FILES[@]}" "${SEO_FILES[@]}")

# Array to hold selected files
SELECTED_FILES=()

# Helper function to read input robustly, checking for terminal presence/dev/tty and EOF
INPUT_VAL=""
read_input() {
    INPUT_VAL=""
    if [ -t 0 ]; then
        if ! read -r INPUT_VAL; then
            echo -e "\n${YELLOW}⚠️ Input stream closed. Setup aborted.${NC}" >&2
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    elif [ -c /dev/tty ] && [ -r /dev/tty ] && [ -w /dev/tty ]; then
        if ! read -r INPUT_VAL < /dev/tty; then
            echo -e "\n${YELLOW}⚠️ Input stream closed. Setup aborted.${NC}" >&2
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    else
        echo -e "\n${RED}❌ Error: No interactive terminal or /dev/tty available.${NC}" >&2
        rm -rf "$TEMP_DIR"
        exit 1
    fi
}

# Helper function to prompt yes/no
prompt_yes_no() {
    local question="$1"
    local default="$2" # Y or N
    local prompt
    if [ "$default" = "Y" ]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    while true; do
        echo -n -e "❓ $question $prompt: "
        read_input
        local choice="$INPUT_VAL"
        if [ -z "$choice" ]; then
            choice="$default"
        fi
        case "$choice" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Helper function to get descriptions for the files
get_file_desc() {
    case "$1" in
        "_overview.md") echo "High level lifecycle & file structure overview";;
        "_filestructure.md") echo "Standardized high-level folder structure";;
        "_conventions.md") echo "Naming conventions, TS configs, and commit rules";;
        "_database.md") echo "Prisma ORM schemas, migration & seeding patterns";;
        "_authentication.md") echo "Clerk verification & local DB synchronization";;
        "_authorization.md") echo "RBAC, API route guards, and custom token claims";;
        "_security.md") echo "OWASP security checklists & input sanitization";;
        "_rate_limiting.md") echo "Rate limiting parameters & Redis backup strategy";;
        "_modules.md") echo "Route, controller, service, repo scaffold guidelines";;
        "_error_handling.md") echo "Custom exception architecture & global middleware";;
        "_validation.md") echo "Type-safe request validation with Zod schemas";;
        "_api_response.md") echo "Standardized API envelopes for all response types";;
        "_middleware.md") echo "Correlation IDs, CORS, and default secure headers";;
        "_logging.md") echo "Winston custom transports & context log injection";;
        "_pagination.md") echo "Standardized cursor and offset pagination boundaries";;
        "_file_upload.md") echo "Multer validators & database record mappings";;
        "_audit.md") echo "Append-only relational mutations audit log schema";;
        "_environment.md") echo "Type-safe environment variable assertions on start";;
        "_testing.md") echo "Integration testing schemas & mocking conventions";;
        "_deployment.md") echo "Docker architectures & server health check standards";;
        "_seo.md") echo "Metadata, sitemaps, robots.txt, and JSON-LD rules";;
        "_geo.md") echo "AI search engine citation rules & GEO parameters";;
        *) echo "";;
    esac
}

echo -e "\n${BOLD}🐳 How would you like to install the standard backend blueprints?${NC}"
echo -e "  ${GREEN}1)${NC} All Blueprints (Recommended - Complete 22-specification suite)"
echo -e "  ${GREEN}2)${NC} Category-based Selection (Meta, Auth, Data, Core API, DevOps, SEO/GEO)"
echo -e "  ${GREEN}3)${NC} Custom File Selection (Select individual blueprints)"

while true; do
    echo -n -e "\n👉 Enter choice [1-3]: "
    read_input
    opt="$INPUT_VAL"
    case "$opt" in
        1)
            SELECTED_FILES=("${ALL_FILES[@]}")
            break
            ;;
        2)
            echo -e "\n${CYAN}--- Category-based Selection ---${NC}"
            if prompt_yes_no "Include Meta Blueprints? (overview, filestructure, conventions)" "Y"; then
                SELECTED_FILES+=("${META_FILES[@]}")
            fi
            if prompt_yes_no "Include Database & Persistence Blueprints? (Prisma/drizzle ORM schemas)" "Y"; then
                SELECTED_FILES+=("${DATABASE_FILES[@]}")
            fi
            if prompt_yes_no "Include Security & Authentication Blueprints? (Clerk auth, RBAC, rate-limiting)" "Y"; then
                SELECTED_FILES+=("${AUTH_FILES[@]}")
            fi
            if prompt_yes_no "Include Core API Architecture Blueprints? (modules, validations, errors, logging)" "Y"; then
                SELECTED_FILES+=("${CORE_FILES[@]}")
            fi
            if prompt_yes_no "Include Testing & DevOps Blueprints? (testing, docker deployment)" "Y"; then
                SELECTED_FILES+=("${DEVOPS_FILES[@]}")
            fi
            if prompt_yes_no "Include SEO & GEO Blueprints? (sitemaps, robots, AI search engine citations)" "Y"; then
                SELECTED_FILES+=("${SEO_FILES[@]}")
            fi
            break
            ;;
        3)
            echo -e "\n${CYAN}--- Custom File Selection ---${NC}"
            for f in "${ALL_FILES[@]}"; do
                desc=$(get_file_desc "$f")
                if prompt_yes_no "Include $f ($desc)?" "Y"; then
                    SELECTED_FILES+=("$f")
                fi
            done
            break
            ;;
        *)
            echo -e "${RED}Invalid selection. Please choose 1, 2, or 3.${NC}"
            ;;
    esac
done

if [ ${#SELECTED_FILES[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠️ No files selected. Setup aborted.${NC}"
    rm -rf "$TEMP_DIR"
    exit 0
fi

# 3. Create destination directory and copy selected files
mkdir -p "$DEST_DIR/schema"

INSTALLED_COUNT=0
for f in "${SELECTED_FILES[@]}"; do
    if [ -f "$TEMP_DIR/schema/$f" ]; then
        cp "$TEMP_DIR/schema/$f" "$DEST_DIR/schema/"
        ((INSTALLED_COUNT++))
    fi
done

# Remove any old unselected blueprints from the schema folder to ensure a clean sync
for f in "${ALL_FILES[@]}"; do
    is_selected=false
    for sel in "${SELECTED_FILES[@]}"; do
        if [ "$sel" = "$f" ]; then
            is_selected=true
            break
        fi
    done
    if [ "$is_selected" = false ] && [ -f "$DEST_DIR/schema/$f" ]; then
        rm "$DEST_DIR/schema/$f"
    fi
done

# Cleanup temp
rm -rf "$TEMP_DIR"

echo -e "\n${GREEN}✅ Setup complete! Installed ${INSTALLED_COUNT} blueprints in $DEST_DIR/schema${NC}"