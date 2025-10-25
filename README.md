# AI Agents Project

This repository contains AI agent configurations for various development frameworks and tools.

## Structure

```
.
├── .cursor/
│   └── agents/
│       └── laravel/
│           └── AGENTS.md          # Laravel Senior Engineer agent for Cursor
├── .claude/
│   └── agents/
│       └── engineering/
│           └── laravel-senior-engineer.md  # Claude Code agent
├── .ulpi/
│   └── agents/
│       └── engineering/
│           └── laravel-senior-engineer.yaml  # ULPI agent configuration
└── .mcp.json                      # MCP server configurations
```

## MCP Servers

This project uses Model Context Protocol (MCP) servers to extend AI capabilities:

### Context7
Provides enhanced context management capabilities.

### Chrome DevTools
Allows Claude Code to control and interact with Chrome browser via the DevTools Protocol.

#### Setup Chrome DevTools MCP

**1. Launch Chrome with Remote Debugging**

Before using the Chrome DevTools MCP server, you need to launch Chrome with remote debugging enabled:

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --remote-debugging-port=9222 \
  --user-data-dir="$(mktemp -d /tmp/chrome-debug-XXXXXX)" \
  --no-first-run \
  --no-default-browser-check
```

**Explanation:**
- `--remote-debugging-port=9222`: Enables Chrome DevTools Protocol on port 9222
- `--user-data-dir="$(mktemp -d /tmp/chrome-debug-XXXXXX)"`: Uses a temporary profile directory
- `--no-first-run`: Skips first-run wizards
- `--no-default-browser-check`: Skips default browser check

**2. MCP Configuration**

The Chrome DevTools MCP server is already configured in `.mcp.json`:

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": ["-y", "chrome-devtools-mcp@latest", "-u", "http://localhost:9222"]
    }
  }
}
```

**3. Usage**

Once Chrome is running with remote debugging and the MCP server is configured, Claude Code can:
- Navigate to URLs
- Click elements
- Fill forms
- Take screenshots
- Execute JavaScript
- Inspect page content
- And more browser automation tasks

**Quick Start Script**

Create a shell script to launch Chrome for debugging:

```bash
#!/bin/bash
# launch-chrome-debug.sh

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --remote-debugging-port=9222 \
  --user-data-dir="$(mktemp -d /tmp/chrome-debug-XXXXXX)" \
  --no-first-run \
  --no-default-browser-check &

echo "Chrome launched with remote debugging on port 9222"
echo "You can now use Claude Code with Chrome DevTools MCP"
```

Make it executable:
```bash
chmod +x launch-chrome-debug.sh
./launch-chrome-debug.sh
```

## Cursor Agents

### Laravel Agent

The Laravel Senior Engineer agent (`.cursor/agents/laravel/AGENTS.md`) provides expert guidance for Laravel 12.x development, including:

- Multi-database architectures (MySQL, Redis, DynamoDB)
- Queue systems with Laravel Horizon
- Service layer patterns
- API development with FormRequests and Resources
- Production-ready patterns and best practices

**Usage in Cursor:**
- Automatically applies when working in the `laravel/` directory
- Manually invoke with `@AGENTS` reference
- Combines hierarchically with parent directory instructions

## Claude Code Agents

Located in `.claude/agents/engineering/`, these agents provide specialized guidance for Claude Code users.

## ULPI Agents

Located in `.ulpi/agents/engineering/`, these YAML-based agent configurations work with ULPI-compatible systems.

---

## License

MIT
