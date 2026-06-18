# Peristyle Grocery Cart Skill

An AI agent skill that turns a recipe into a ready-to-checkout **Kroger grocery
cart** — ingredients matched to real products at your store, confirmed by you,
then added with one step. Built for Claude Code and any agent that supports the
[Agent Skills spec](https://agentskills.io).

## Available Skill

| Skill                                                    | Description                                                                                                                                                                                         |
| -------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [peristyle-grocery-cart](skills/peristyle-grocery-cart/) | Turn a recipe into a ready-to-checkout Kroger grocery cart. Use when someone says "add this recipe to my cart", "shop these ingredients", "build my grocery cart", or "add this to my Kroger cart". |

## Installation

### Option 1: CLI Install (Recommended)

Use [npx skills](https://github.com/vercel-labs/skills) to install the skill directly:

```bash
npx skills add peristyle-io/grocery-cart-skills
```

This installs to your `.agents/skills/` directory (and symlinks into
`.claude/skills/` for Claude Code compatibility).

### Option 2: Clone and Copy

```bash
git clone https://github.com/peristyle-io/grocery-cart-skills.git
cp -r peristyle-cart-skills/skills/* .agents/skills/
```

## Connecting the MCP server

Browsing and searching recipes needs no key or setup. For the cart flow, connect
the `peristyle-grocery-cart` MCP server — it handles Kroger OAuth and stores the
session for you (nothing to copy or paste). You only connect a Kroger account at
the moment you want to add items to a cart.

### Claude.ai (and any URL-capable MCP client)

The server is hosted at `https://mcp.peristyle.io/mcp` — no install needed.

**Claude.ai:** Settings → Integrations → Add integration → enter `https://mcp.peristyle.io/mcp`

**Cursor** (`.cursor/mcp.json`):

```json
{
  "mcpServers": {
    "peristyle-grocery-cart": {
      "type": "http",
      "url": "https://mcp.peristyle.io/mcp"
    }
  }
}
```

**Zed** (settings → `context_servers`):

```json
{
  "context_servers": {
    "peristyle-grocery-cart": {
      "url": "https://mcp.peristyle.io/mcp"
    }
  }
}
```

**Session persistence:** `finish_kroger_connection()` returns a `pk_…` key after
you connect Kroger. Add it as `Authorization: Bearer pk_…` in your client's
header config to stay connected across sessions. Without it the Kroger connect
flow runs again on each new session (takes ~30 seconds).

### Claude Code (local subprocess)

```bash
claude mcp add peristyle-grocery-cart -- peristyle-grocery-cart-mcp
```

Or in `.mcp.json`:

```json
{
  "mcpServers": {
    "peristyle-grocery-cart": {
      "command": "peristyle-grocery-cart-mcp"
    }
  }
}
```

The Kroger session is saved automatically to `~/.config/peristyle-grocery-cart/api-key`
— nothing to copy or paste across sessions.

## Contributing

Found a way to improve the skill? PRs and issues welcome.

## License

[MIT](LICENSE)
