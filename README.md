# Peristyle Grocery Cart Skill

An AI agent skill that turns a recipe into a ready-to-checkout **Kroger grocery
cart** — ingredients matched to real products at your store, confirmed by you,
then added with one step. Built for Claude Code and any agent that supports the
[Agent Skills spec](https://agentskills.io). Formatted after
[marketingskills](https://github.com/coreyhaines31/marketingskills).

> **Note:** The Peristyle Grocery Cart API is not yet publicly available. The
> skill definitions describe what will be possible once the API launches — none
> of the cart-building functionality works today.

## Available Skills

| Skill | Description |
|-------|-------------|
| [peristyle-grocery-cart](skills/peristyle-grocery-cart/) | Turn a recipe into a ready-to-checkout Kroger grocery cart. Use when someone says "add this recipe to my cart", "shop these ingredients", "build my grocery cart", or "add this to my Kroger cart". |

## Installation

### Option 1: CLI Install (Recommended)

Use [npx skills](https://github.com/vercel-labs/skills) to install the skill directly:

```bash
npx skills add kthedges12/peristyle-cart-skills
```

This installs to your `.agents/skills/` directory (and symlinks into
`.claude/skills/` for Claude Code compatibility).

### Option 2: Claude Code Plugin

```bash
/plugin marketplace add kthedges12/peristyle-cart-skills
/plugin install peristyle-grocery-cart
```

### Option 3: Clone and Copy

```bash
git clone https://github.com/kthedges12/peristyle-cart-skills.git
cp -r peristyle-cart-skills/skills/* .agents/skills/
```

## Contributing

Found a way to improve the skill? PRs and issues welcome. Run
`./validate-skills.sh` before submitting to check the `SKILL.md` format.

## License

[MIT](LICENSE)
