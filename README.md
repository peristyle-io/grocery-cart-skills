# Peristyle Grocery Cart Skills

Agent skills for turning recipes into a ready-to-checkout grocery cart at **Kroger** or **Walmart**. Compatible with Claude Code and any agent that supports the [Agent Skills spec](https://agentskills.io).

## Skills

| Skill | Description |
|-------|-------------|
| [grocery-cart](skills/grocery-cart/) | Match recipe ingredients to store products and build a cart — Kroger (OAuth) or Walmart (Add-to-Cart link). |

## Installation

```bash
npx skills add https://github.com/peristyle-io/grocery-cart-skills --skill grocery-cart
```

## MCP Server

Pair the skill with the MCP server for full cart support (product matching, add to cart). Kroger requires a one-time OAuth connect; Walmart tools need `PERISTYLE_GROCERY_CART_WALMART_ENABLED=true` on the MCP server and require no user sign-in.

**Claude Code:**
```bash
claude mcp add peristyle-grocery-cart -- peristyle-grocery-cart-mcp
```

**Claude.ai, Cursor, Zed:** connect to `https://mcp.peristyle.io/mcp` in your client's MCP or integrations settings.

## License

[MIT](LICENSE)
