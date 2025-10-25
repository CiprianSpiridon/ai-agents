#!/bin/bash

# AI Agents Setup Script
# https://github.com/CiprianSpiridon/ai-agents
#
# This script sets up AI agent configurations for ULPI, Amazon Q, Cursor, and Claude Code
# Run remotely: curl -fsSL https://raw.githubusercontent.com/CiprianSpiridon/ai-agents/main/.ulpi/tools/setup.sh | bash -s -- [target-directory]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
TARGET_DIR="${1:-.}"
CHROME_PORT="${2:-9222}"
REPO_URL="https://raw.githubusercontent.com/CiprianSpiridon/ai-agents/main"

# Helper functions
print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# Start setup
print_header "AI Agents Configuration Setup"

echo -e "Target directory: ${GREEN}$TARGET_DIR${NC}"
echo -e "Chrome debug port: ${GREEN}$CHROME_PORT${NC}"
echo ""

# Create target directory if it doesn't exist
if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
    print_success "Created directory: $TARGET_DIR"
else
    print_info "Directory already exists: $TARGET_DIR"
fi

cd "$TARGET_DIR"

# Function to download file from repo
download_file() {
    local source_path=$1
    local target_path=$2
    local url="$REPO_URL/$source_path"

    mkdir -p "$(dirname "$target_path")"

    if command -v curl &> /dev/null; then
        curl -fsSL "$url" -o "$target_path" 2>/dev/null || {
            print_error "Failed to download $source_path"
            return 1
        }
    elif command -v wget &> /dev/null; then
        wget -q "$url" -O "$target_path" 2>/dev/null || {
            print_error "Failed to download $source_path"
            return 1
        }
    else
        print_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi

    return 0
}

# Create directory structures
print_header "Creating Directory Structure"

mkdir -p .amazonq/rules
mkdir -p .cursor/agents/laravel
mkdir -p .claude/agents/engineering
mkdir -p .ulpi/agents/engineering
mkdir -p .ulpi/tools

print_success "Created .amazonq/rules/"
print_success "Created .cursor/agents/"
print_success "Created .claude/agents/"
print_success "Created .ulpi/agents/"
print_success "Created .ulpi/tools/"

# Download agent configuration files
print_header "Downloading Agent Configurations"

# Amazon Q
if download_file ".amazonq/rules/laravel.rule.md" ".amazonq/rules/laravel.rule.md"; then
    print_success "Amazon Q Laravel rule"
fi

# Cursor
if download_file ".cursor/agents/AGENTS.md" ".cursor/agents/AGENTS.md"; then
    print_success "Cursor global agents"
fi

if download_file ".cursor/agents/laravel/AGENTS.md" ".cursor/agents/laravel/AGENTS.md"; then
    print_success "Cursor Laravel agent"
fi

# Claude Code
if download_file ".claude/agents/engineering/laravel-senior-engineer.md" ".claude/agents/engineering/laravel-senior-engineer.md"; then
    print_success "Claude Code Laravel agent"
fi

# ULPI
if download_file ".ulpi/agents/engineering/laravel-senior-engineer.yaml" ".ulpi/agents/engineering/laravel-senior-engineer.yaml"; then
    print_success "ULPI Laravel agent"
fi

# Download tools
if download_file ".ulpi/tools/launch-chrome-debug.sh" ".ulpi/tools/launch-chrome-debug.sh"; then
    chmod +x ".ulpi/tools/launch-chrome-debug.sh"
    print_success "Chrome debug launcher (executable)"
fi

# Create .mcp.json for project-level MCP servers
print_header "Creating MCP Configuration"

cat > .mcp.json <<EOF
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest", "-u", "http://localhost:$CHROME_PORT"]
    }
  }
}
EOF

print_success "Created .mcp.json with context7 and chrome-devtools"

# Update global Amazon Q MCP configuration
print_header "Updating Amazon Q Global MCP Configuration"

AMAZONQ_MCP_DIR="$HOME/.aws/amazonq"
AMAZONQ_MCP_FILE="$AMAZONQ_MCP_DIR/mcp.json"

mkdir -p "$AMAZONQ_MCP_DIR"

if [ -f "$AMAZONQ_MCP_FILE" ]; then
    print_info "Amazon Q MCP config already exists at $AMAZONQ_MCP_FILE"

    # Check if context7 and chrome-devtools already exist
    if grep -q "context7" "$AMAZONQ_MCP_FILE" && grep -q "chrome-devtools" "$AMAZONQ_MCP_FILE"; then
        print_info "MCP servers already configured in Amazon Q"
    else
        print_info "Backing up existing config to mcp.json.backup"
        cp "$AMAZONQ_MCP_FILE" "$AMAZONQ_MCP_FILE.backup"

        # Parse existing JSON and merge (basic approach - overwrites mcpServers section)
        cat > "$AMAZONQ_MCP_FILE" <<EOF
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest", "-u", "http://localhost:$CHROME_PORT"]
    }
  }
}
EOF
        print_success "Updated Amazon Q global MCP configuration"
    fi
else
    cat > "$AMAZONQ_MCP_FILE" <<EOF
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest", "-u", "http://localhost:$CHROME_PORT"]
    }
  }
}
EOF
    print_success "Created Amazon Q global MCP configuration"
fi

# Create README if it doesn't exist
if [ ! -f "README.md" ]; then
    print_header "Creating README"

    if download_file "README.md" "README.md"; then
        print_success "Created README.md"
    fi
fi

# Final summary
print_header "Setup Complete!"

echo -e "AI agent configurations have been set up in: ${GREEN}$TARGET_DIR${NC}\n"

echo "📁 Directory structure created:"
echo "   ├── .amazonq/rules/          (Amazon Q Developer)"
echo "   ├── .cursor/agents/          (Cursor AI)"
echo "   ├── .claude/agents/          (Claude Code)"
echo "   ├── .ulpi/agents/            (ULPI)"
echo "   ├── .ulpi/tools/             (Utility scripts)"
echo "   └── .mcp.json                (MCP server config)"
echo ""

echo "🔧 MCP Servers configured:"
echo "   ├── context7                 (Enhanced context management)"
echo "   └── chrome-devtools          (Browser automation)"
echo ""

echo "🌍 Global configurations updated:"
echo "   └── ~/.aws/amazonq/mcp.json  (Amazon Q global MCP)"
echo ""

echo "🚀 Next steps:"
echo ""
echo "1. Launch Chrome for debugging:"
echo "   ${GREEN}./.ulpi/tools/launch-chrome-debug.sh${NC}"
echo ""
echo "2. Start using your AI tools:"
echo "   - ULPI: Use .ulpi/agents/ configurations"
echo "   - Amazon Q: Rules automatically apply from .amazonq/rules/"
echo "   - Cursor: Agents auto-apply in respective directories"
echo "   - Claude Code: Use .claude/agents/ configurations"
echo ""
echo "3. Customize for your project:"
echo "   - Modify port in .mcp.json if needed (currently: $CHROME_PORT)"
echo "   - Add framework-specific agents to respective directories"
echo ""

print_success "All done! Happy coding with AI assistance! 🤖"
echo ""
echo "Repository: https://github.com/CiprianSpiridon/ai-agents"
echo "🤖 Generated with https://ulpi.io"
echo ""
