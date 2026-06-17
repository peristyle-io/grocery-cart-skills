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

## Recommended: pair with the MCP server

**browsing and searching
recipes needs no key or setup at all.** For the cart flow, the
`peristyle-grocery-cart` MCP server handles the entire Kroger OAuth connect and
stores the session for you (nothing to copy or paste):

```bash
claude mcp add peristyle-grocery-cart -- peristyle-grocery-cart-mcp
```

You only connect a Kroger account at the moment you want to add items to a cart.
See the skill's "How auth works" and "Setting up the MCP server" sections for
details.

## Contributing

Found a way to improve the skill? PRs and issues welcome.

## License

[MIT](LICENSE)
