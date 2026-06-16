---
name: peristyle-grocery-cart
description: >-
  Turn a recipe into a ready-to-checkout Kroger grocery cart. Use when someone
  says "add this recipe to my cart", "shop these ingredients", "build my grocery
  cart", or "add this to my Kroger cart". Handles store auth (OAuth), matching
  ingredients to real products at the user's store, confirming picks, and adding
  them to the cart. Kroger is the only connected store today.
---

# Peristyle Grocery Cart

Turn a recipe into a ready-to-checkout **Kroger grocery cart** — ingredients
matched to real products at your store, confirmed by you, then added with one
step. You review and check out in the Kroger app or on kroger.com.

**Hard limit:** the API adds items to your cart but cannot place the order or
take payment. Checkout always happens in the Kroger app or on kroger.com.

---

## What you need before starting

- A **running Peristyle Grocery Cart API** — get the URL from whoever set it up, or
  run it yourself (see the [README](https://github.com/kthedges12/peristyle-grocery-list)).
  Default: `http://localhost:8001`. Confirm it's up: `GET /v1/health` → `{"status":"ok"}`.
- A **Kroger account** — free at kroger.com. You'll connect it below.

---

## Step 1 — Find the recipe

Search the recipe index by keyword or pick from a list:

```
POST /v1/recipes/search   {"query": "pasta carbonara", "limit": 10}
GET  /v1/recipes          (browse recent)
```

Confirm the recipe title with the user before continuing. Get its `recipe_id`.

---

## Step 2 — Connect to Kroger (first time only)

The connect flow is automatic — the user never copies, pastes, or reads back any
key or code. Their Kroger tokens and a per-user credential are stored server-side
in the database; the MCP client picks up the session over its own back channel.

**Using the MCP tools (recommended):**

1. Call `connect_kroger()` → returns a `login_url`.
2. Ask the user to open `login_url`, sign in to Kroger, and approve access.
3. Call `finish_kroger_connection()` — it waits for the user to finish and saves
   the session automatically to `~/.config/peristyle-grocery-cart/api-key`. If it returns
   `"waiting"`, give the user a moment and call it again.

That's it — no key to paste, nothing to read aloud.

**Raw HTTP (if not using MCP):**

```
POST /v1/kroger/auth/start        → { link_token, login_url }
  (open login_url in a browser, sign in)
POST /v1/kroger/auth/poll  { "link_token": "…" }
  → { "status": "pending" }  while waiting
  → { "status": "connected", "api_key": "pk_…" }  once done (returned once)
```

Save the returned `api_key` and send it as `Authorization: Bearer pk_…` on cart
requests. To check connection state later: `GET /v1/kroger/auth/status` (with the
key). A direct browser visit to `/v1/kroger/auth/login` without a `link_token`
still works as a manual fallback and shows the key on the callback page.

---

## Step 3 — Match ingredients to products

```
POST /v1/kroger/match   {"recipe_id": "<id>"}
```

Each ingredient comes back with a `suggested` product and `candidates`
(alternatives). Each product has `description`, `brand`, `size`,
`price_regular`, `price_promo`, and a `upc`.

Note items where `matched: false` and any `pantry_staple: true` lines
(salt, water, oil) the user likely already has.

---

## Step 4 — Confirm with the user (required)

Show each suggestion clearly:

> For **baby spinach** → *Kroger Baby Spinach, 10 oz — $2.49*
> Alternatives: [list candidates]

Ask the user to:
- Confirm each pick or swap to an alternative `upc`
- Set quantities (default: 1 per ingredient)
- Drop pantry staples they already have
- Skip anything that didn't match

**Do not add anything the user hasn't explicitly confirmed.**

---

## Step 5 — Add to cart

```
POST /v1/kroger/cart/add
Authorization: Bearer pk_…

{
  "items": [{"upc": "…", "quantity": 1}],
  "modality": "PICKUP",
  "recipe_id": "…"
}
```

Use `"DELIVERY"` if the user prefers it. Include `recipe_id` so the order is
attributed to the recipe and creator.

On success, report `added_count` and tell the user to **open the Kroger app or
kroger.com to review and check out**.

Always surface the recipe's `source_url` and creator name.

---

## Step 6 — Close the loop (after user checks out)

The Kroger API has no order-confirmation or checkout-status endpoint — there is
no way to verify whether the user actually completed checkout. Do **not** claim
the order was placed.

Instead, after adding to cart, invite the user to report back once they've
reviewed the cart:

> "All set — open the Kroger app or kroger.com to review and check out.
> Once you're done, let me know if you swapped anything or ran into anything
> out of stock. I'll save your preferences for next time."

**When the user responds**, ask at most three targeted follow-up questions:

1. **Swaps** — "Did you swap any of the suggested products for a different
   brand, size, or variety?"
2. **Out of stock** — "Anything the store didn't have that I should know
   about?"
3. **Quantity changes** — "Did you bump any quantities up or down?"

Then **save what you learn to Claude memory** so future cart runs use better
defaults. Good things to record:

- Brand preferences per ingredient category ("prefers Kroger-brand olive oil
  over premium brands", "always buys Boar's Head deli meat")
- Size preferences ("buys 16 oz pasta, not 12 oz")
- Items the user always already has at home ("never needs to buy kosher salt,
  pantry oils, or garlic")
- Chronic out-of-stock items at their store ("Kroger near this user rarely
  stocks fresh dill — suggest dried as default")
- Substitution patterns ("swaps feta → cotija consistently")

Keep memory entries short and specific. Tag them with the store location if
relevant. Update existing entries rather than creating duplicates.

---

## API reference

| Method | Path | Auth |
|--------|------|------|
| `GET` | `/v1/health` | none |
| `GET` | `/v1/recipes` | optional |
| `POST` | `/v1/recipes/search` | optional |
| `GET` | `/v1/recipes/{id}/ingredients` | optional |
| `POST` | `/v1/kroger/auth/start` | none |
| `GET` | `/v1/kroger/auth/login` | none (browser) |
| `POST` | `/v1/kroger/auth/poll` | none (holds link_token) |
| `GET` | `/v1/kroger/auth/status` | user API key |
| `GET` | `/v1/kroger/locations?zip=` | optional |
| `POST` | `/v1/kroger/match` | optional |
| `POST` | `/v1/kroger/cart/add` | user API key |

Send the user API key as `Authorization: Bearer pk_…`. MCP users: set
`PERISTYLE_API_KEY` in their MCP server config.

---

## Guardrails

- Never claim the order was placed or payment taken — you fill the cart only.
- Always confirm products before adding — wrong groceries are costly.
- Only add UPCs returned by `/match` — never invent them.
- Prices and availability depend on the store location; say which store you matched against.
- Kroger is the only connected store today — don't promise others.
- Default quantity is 1 unit of the matched product, not the recipe amount.
- Always surface `source_url` and creator attribution.
