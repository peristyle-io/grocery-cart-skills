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

## Contributing

Found a way to improve the skill? PRs and issues welcome.

## License

[MIT](LICENSE)
