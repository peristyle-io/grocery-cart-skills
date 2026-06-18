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

## How auth works (read this first)

There are exactly two tiers — nothing in between:

| What you're doing | Auth needed |
|-------------------|-------------|
| **Browsing / searching recipes, reading ingredients** | **None.** Fully public. No key, no setup. |
| **Anything that touches Kroger** (match a recipe to products, search the catalog, add to cart) | The user connects their **Kroger account once** (OAuth). |

So: discover recipes freely, and only ask the user to connect Kroger at the
moment they want to actually shop. You never need a pre-provisioned API key to
get started.

**Two ways to integrate — pick one:**

- **MCP server (recommended).** The `peristyle-grocery-cart` MCP server exposes
  every step as a tool and handles the entire Kroger OAuth flow + local session
  storage for you. There is nothing to paste or configure. If it's available,
  use the tools and ignore the raw HTTP details below. See
  [Setting up the MCP server](#setting-up-the-mcp-server).
- **Raw HTTP.** Call `https://api.peristyle.io` directly. Recipe routes need no
  auth. For the Kroger connect flow, follow [Connecting Kroger over raw
  HTTP](#connecting-kroger-over-raw-http) exactly — the response shapes matter.

---

## Step 1 — Find the recipe (no auth)

MCP: `search_recipes(query=…)` or `list_recipes()`.

Raw HTTP:

```
POST /v1/recipes/search   {"query": "pasta carbonara", "limit": 10}
GET  /v1/recipes          (browse newest; ?q= for full-text)
GET  /v1/recipes/{id}/ingredients
```

No `Authorization` header required. Confirm the recipe title with the user and
keep its `recipe_id`.

---

## Step 2 — Connect Kroger (only when the user wants to shop)

Do this the first time the user wants to act on a recipe. Skip it entirely if
they're just browsing.

**MCP (recommended):**

1. Call `connect_kroger()` → returns a `login_url`.
2. Ask the user to open `login_url`, sign in to Kroger, and approve access.
3. Call `finish_kroger_connection()` — it polls until they finish and saves the
   session automatically to `~/.config/peristyle-grocery-cart/api-key`. Nothing
   to copy or paste.
4. If it returns `"waiting"`, give the user a moment and call it again.

You can check status anytime with `kroger_auth_status()`.

**Raw HTTP:** see [Connecting Kroger over raw HTTP](#connecting-kroger-over-raw-http).

---

## Step 3 — Match ingredients to products (requires connected account)

MCP: `match_recipe_to_kroger(recipe_id, location_id?)`.

Raw HTTP: `POST /v1/kroger/match {"recipe_id": "<id>"}` with
`Authorization: Bearer pk_…`.

Each ingredient comes back with a `suggested` product and `candidates`
(alternatives). Each product has `description`, `brand`, `size`,
`price_regular`, `price_promo`, and a `upc`. Note items where `matched: false`
and any `pantry_staple: true` lines (salt, water, oil) the user likely has.

Omit `location_id` to use the user's saved default store (set via
`set_preference`), then the server default. If neither is set, match returns a
400 asking for a store — find one with `GET /v1/kroger/locations?zip=…`
(also requires the connected account).

---

## Step 4 — Confirm with the user (required)

Show each suggestion clearly:

> For **baby spinach** → *Kroger Baby Spinach, 10 oz — $2.49*
> Alternatives: [list candidates]

Ask the user to confirm each pick or swap to an alternative `upc`, set
quantities (default 1), drop pantry staples they have, and skip non-matches.

**Do not add anything the user hasn't explicitly confirmed.**

---

## Step 5 — Add to cart (requires connected account)

MCP: `kroger_add_to_cart(items=[{"upc": "…", "quantity": 1}], modality?, recipe_id?)`.

Raw HTTP:

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
attributed to the recipe and creator. On success, report `added_count` and tell
the user to **open the Kroger app or kroger.com to review and check out**.

Always surface the recipe's `source_url` and creator name.

---

## Step 6 — Close the loop (after user checks out)

The Kroger API has no order-confirmation or checkout-status endpoint — there is
no way to verify whether the user actually completed checkout. Do **not** claim
the order was placed.

After adding to cart, invite the user to report back:

> "All set — open the Kroger app or kroger.com to review and check out.
> Once you're done, let me know if you swapped anything or ran into anything
> out of stock. I'll save your preferences for next time."

**When the user responds**, ask at most three targeted follow-up questions:
swaps, out-of-stock items, and quantity changes. Then **save what you learn to
memory** (MCP: `set_preference`) so future cart runs use better defaults — brand
preferences, size preferences, pantry staples to skip, chronic out-of-stock
items, substitution patterns. Keep entries short; update rather than duplicate.

---

## Setting up the MCP server

Two options — remote (no install) or local (needs the package):

### Remote — connect by URL (Claude.ai, Cursor, Zed, any URL-capable client)

The server is hosted at **`https://mcp.peristyle.io/mcp`** (streamable-http).
No package install needed.

Add it in Claude.ai → Settings → Integrations, or in your client's MCP config:

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

**Session persistence:** After connecting Kroger, `finish_kroger_connection()`
returns a `pk_…` key in its response. Add it as a header to stay connected
across sessions:

```json
{
  "mcpServers": {
    "peristyle-grocery-cart": {
      "type": "http",
      "url": "https://mcp.peristyle.io/mcp",
      "headers": { "Authorization": "Bearer pk_…" }
    }
  }
}
```

Without the header the Kroger session lasts only for the current MCP session;
the `connect_kroger` → `finish_kroger_connection` flow works again on reconnect.

### Local — stdio subprocess (Claude Code, any stdio-capable client)

Requires the package: `pip install peristyle-grocery-cart`

Register with Claude Code (one line):

```bash
claude mcp add peristyle-grocery-cart -- peristyle-grocery-cart-mcp
```

Or add to `.mcp.json`:

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
— no key to copy or paste. Override the API base with
`PERISTYLE_GROCERY_CART_API_BASE_URL` to point at a local server.

---

## Connecting Kroger over raw HTTP

Only needed if you are **not** using the MCP server. The endpoints are open (no
key) because they exist to mint the user's key.

1. `POST /v1/kroger/auth/start` → returns `{"link_token": "…", "login_url": "…"}`.
   **One call gives you both** — the `login_url` is the Kroger sign-in URL; the
   `link_token` is what you poll with. (Older servers may omit `login_url`; if so,
   `POST /v1/kroger/auth/login {"link_token": "…"}` → `{"authorize_url": "…"}`.)
2. Send the user to `login_url`. They sign in to Kroger and approve access.
3. Poll `POST /v1/kroger/auth/poll {"link_token": "…"}` every ~3s. It returns
   `{"status": "pending"}` until done, then `{"status": "connected", "api_key":
   "pk_…"}` **once**. Save that `pk_…` and send it as `Authorization: Bearer pk_…`
   on all Kroger action calls. (`410` means the link expired — start over.)

The key is delivered over this back channel — never shown in the browser.

---

## API reference

Base URL: `https://api.peristyle.io`

| Method | Path | Auth |
|--------|------|------|
| `GET` | `/v1/health` | none |
| `GET` | `/v1/recipes` | **none (public)** |
| `POST` | `/v1/recipes/search` | **none (public)** |
| `GET` | `/v1/recipes/{id}` | **none (public)** |
| `GET` | `/v1/recipes/{id}/ingredients` | **none (public)** |
| `POST` | `/v1/kroger/auth/start` | none (returns `link_token` + `login_url`) |
| `POST` | `/v1/kroger/auth/login` | none (legacy; `link_token` → `authorize_url`) |
| `POST` | `/v1/kroger/auth/poll` | none (holds `link_token`) |
| `GET` | `/v1/kroger/auth/status` | connected account (`pk_…`) |
| `GET` | `/v1/kroger/locations?zip=` | connected account (`pk_…`) |
| `GET` | `/v1/kroger/products?query=` | connected account (`pk_…`) |
| `POST` | `/v1/kroger/match` | connected account (`pk_…`) |
| `POST` | `/v1/kroger/cart/add` | connected account (`pk_…`) |

Send the user key as `Authorization: Bearer pk_…`. MCP users: the
`connect_kroger` / `finish_kroger_connection` flow handles this automatically.

---

## Guardrails

- Never claim the order was placed or payment taken — you fill the cart only.
- Always confirm products before adding — wrong groceries are costly.
- Only add UPCs returned by `/match` — never invent them.
- Prices and availability depend on the store location; say which store you matched against.
- Kroger is the only connected store today — don't promise others.
- Default quantity is 1 unit of the matched product, not the recipe amount.
- Always surface `source_url` and creator attribution.
