# Peristyle Grocery Cart Skills

Agent skills for turning recipes into a ready-to-checkout grocery cart at **Kroger** or **Walmart**. Compatible with Claude Code and any agent that supports the [Agent Skills spec](https://agentskills.io).

## Skills

| Skill | Description |
|-------|-------------|
| [grocery-cart](skills/grocery-cart/) | Match recipe ingredients to store products and build a cart — Kroger (OAuth) or Walmart (Add-to-Cart link). |

## Installation

**Claude plugin** (skill + connector together; claude.ai, Desktop, Cowork, Claude Code):

```text
/plugin marketplace add peristyle-io/grocery-cart-skills
/plugin install grocery-cart@peristyle-cart-skills
```

On claude.ai you can also zip this repo and upload it under **Customize → Plugins**,
then connect the bundled **Peristyle Grocery Cart** connector from the plugin's
Connectors tab.

**Skill only** (any Agent Skills host):

```bash
npx skills add https://github.com/peristyle-io/grocery-cart-skills --skill grocery-cart
```

**ChatGPT:** add `https://mcp.peristyle.io/mcp` as a connector. The server
serves this same skill over MCP (Skills over MCP extension), so ChatGPT can
import it from the connector.

## MCP Server

Pair the skill with the MCP server for full cart support (product matching, add to cart). Kroger requires a one-time OAuth connect; Walmart tools are always available and require no user sign-in.

**Claude Code:**
```bash
claude mcp add peristyle-grocery-cart -- peristyle-grocery-cart-mcp
```

**Claude.ai, Cursor, Zed:** connect to `https://mcp.peristyle.io/mcp` in your client's MCP or integrations settings.

## Use it

Ask for a dish ("shop chicken tikka masala at Walmart") or paste a recipe link.
Claude finds the recipe, matches each ingredient to a real product at your
store, checks what you already have, and shows the final shopping list — an
interactive list with photos, prices, swaps and quantity steppers on hosts
that support MCP Apps and ChatGPT apps. Nothing goes in your cart until you
approve it.

## Data

The plugin sends the recipe or ingredient list you ask about, your store
choice (ZIP or store id), and the products you confirm to the Peristyle
Grocery Cart service at `mcp.peristyle.io`, which calls Kroger's or Walmart's
product APIs on your behalf. Kroger cart writes use your own Kroger sign-in
(OAuth) and are add-only; Walmart carts are a link you open yourself.
Preferences and the opt-in pantry are stored with your Peristyle account;
privacy policy: https://api.peristyle.io/privacy.

## License

[MIT](LICENSE)
