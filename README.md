# Peristyle Grocery Cart Skill

An AI agent skill that turns a recipe into a ready-to-checkout **Kroger grocery
cart** — ingredients matched to real products at your store, confirmed by you,
then added with one step. Built for Claude Code and any agent that supports the
[Agent Skills spec](https://agentskills.io). Formatted after
[marketingskills](https://github.com/coreyhaines31/marketingskills).

This skill talks to the [Peristyle Grocery Cart API](https://github.com/kthedges12/peristyle-grocery-list),
which must be running and reachable. The API can add items to a Kroger cart but
cannot place the order or take payment — checkout always happens in the Kroger
app or on kroger.com.

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

## Requirements

- A **running Peristyle Grocery Cart API** — see the
  [peristyle-grocery-list README](https://github.com/kthedges12/peristyle-grocery-list).
  Default: `http://localhost:8001`.
- A **Kroger account** — free at kroger.com.

## Contributing

Found a way to improve the skill? PRs and issues welcome. Run
`./validate-skills.sh` before submitting to check the `SKILL.md` format.

## License

[MIT](LICENSE)
