# Peristyle Grocery Cart Skills

Agent skills for turning recipes into a ready-to-checkout Kroger grocery cart. Compatible with Claude Code and any agent that supports the [Agent Skills spec](https://agentskills.io).

## Skills

| Skill | Description |
|-------|-------------|
| [peristyle-grocery-cart](skills/peristyle-grocery-cart/) | Turn a recipe into a Kroger grocery cart — match ingredients to products, confirm picks, and add to cart. |

## Installation

```bash
npx skills add https://github.com/peristyle-io/grocery-cart-skills --skill peristyle-grocery-cart
```

## MCP Server

Pair the skill with the MCP server for full cart support (Kroger sign-in, product matching, add to cart).

**Claude Code:**
```bash
claude mcp add peristyle-grocery-cart -- peristyle-grocery-cart-mcp
```

**Claude.ai, Cursor, Zed:** connect to `https://mcp.peristyle.io/mcp` in your client's MCP or integrations settings.

## License

[MIT](LICENSE)
