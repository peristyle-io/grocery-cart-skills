# Raw HTTP fallback

**Read this only when the `peristyle-grocery-cart` MCP server is unavailable.**
The MCP server is the recommended, secure default — it handles Kroger OAuth and
keeps secrets off the agent. Use raw HTTP only when those tools genuinely aren't
present.

Base URL: `https://api.peristyle.io` (the canonical host — see "Pin the host" in
SKILL.md before pointing anywhere else).

---

## Recipe routes (no auth)

```
POST /v1/recipes/search       {"query": "pasta carbonara", "limit": 10}
GET  /v1/recipes              (browse newest; ?q= for full-text)
GET  /v1/recipes/{id}         (detail)
GET  /v1/recipes/{id}/ingredients
```

No `Authorization` header required.

---

## Kroger (OAuth required)

### Connecting

1. `POST /v1/kroger/auth/start` → `{"link_token": "…", "login_url": "…"}`
2. User opens `login_url` and signs in.
3. Poll `POST /v1/kroger/auth/poll {"link_token": "…"}` until
   `{"status": "connected", "api_key": "pk_…"}` (once). Use
   `Authorization: Bearer pk_…` on Kroger action calls.

If you already hold a `pk_…` key (e.g. one issued by the connector OAuth flow
at `/.well-known/oauth-authorization-server`), send it as
`Authorization: Bearer` on the `/auth/start` call: the Kroger account then
attaches to that same user, and the poll returns `{"status": "connected"}`
**without** an `api_key` — keep using the key you have.

### Match → add

```
POST /v1/kroger/match
Authorization: Bearer pk_…

{"recipe_id": "<id>"}
```

```
POST /v1/kroger/cart/add
Authorization: Bearer pk_…

{
  "items": [{"upc": "…", "quantity": 1}],
  "modality": "PICKUP",
  "recipe_id": "…"
}
```

Give the user `checkout_url` from the response when present.

---

## Walmart (no OAuth)

Walmart routes require `WALMART_ENABLED=true` on the server. No user sign-in or
`pk_…` key is ever needed for any Walmart route.

### Match → add

```
POST /v1/walmart/match

{"recipe_id": "<id>"}
```

```
POST /v1/walmart/cart/add

{
  "items": [{"product_id": "945193065", "quantity": 1}],
  "store_id": "5435",
  "recipe_id": "…"
}
```

Response:

```json
{
  "status": "added",
  "store": "walmart",
  "added_count": 5,
  "checkout_url": "https://www.walmart.com/sc/cart/addToCart?items=…",
  "note": "Open the checkout link in your browser while signed in to Walmart…"
}
```

The user **must open `checkout_url` in a browser** while signed in to Walmart.
The API does not write to their cart server-side.

### Catalog search

```
GET /v1/walmart/products?query=baby+spinach&limit=10
GET /v1/walmart/products?item_id=945193065
GET /v1/walmart/locations?zip=78701
```

---

## Full API reference

| Method | Path | Auth |
|--------|------|------|
| `GET` | `/v1/health` | none |
| `GET` | `/v1/recipes` | **none (public)** |
| `POST` | `/v1/recipes/search` | **none (public)** |
| `GET` | `/v1/recipes/{id}` | **none (public)** |
| `POST` | `/v1/kroger/auth/start` | none |
| `POST` | `/v1/kroger/auth/poll` | none |
| `GET` | `/v1/kroger/auth/status` | `pk_…` |
| `GET` | `/v1/kroger/locations?zip=` | none (app credentials) |
| `GET` | `/v1/kroger/products?query=` | `pk_…` |
| `POST` | `/v1/kroger/match` | `pk_…` |
| `POST` | `/v1/kroger/cart/add` | `pk_…` |
| `GET` | `/v1/walmart/locations?zip=` | none |
| `GET` | `/v1/walmart/products?query=` | none |
| `POST` | `/v1/walmart/match` | none |
| `POST` | `/v1/walmart/cart/add` | none |
| `POST` | `/v1/pantry/opt-in` | `pk_…` |
| `GET` | `/v1/pantry` | `pk_…` |
| `PUT` | `/v1/pantry/items` | `pk_…` |
| `POST` | `/v1/pantry/feedback` | `pk_…` |
| `POST` | `/v1/pantry/confirmations/{id}/resolve` | `pk_…` |

MCP users: Kroger connect is handled by `connect_kroger` /
`finish_kroger_connection`. Walmart needs no connect step.

### Pantry (opt-in)

All pantry routes need a `pk_…` key, and every route except `opt-in` requires
the user to have opted in first (403 otherwise). `GET /v1/pantry` returns
items with a decayed `status` (`have` / `probably_out` / `out`), love/hate
`feedback`, and `pending_confirmations`. `PUT /v1/pantry/items` takes
`{"items": [{"name": "whole milk", "state": "have"|"out"|"remove", "staple": true?}]}`.
Cart adds by an opted-in user return a `pantry_confirmation_id`; after the user
checks out, resolve it with
`POST /v1/pantry/confirmations/{id}/resolve {"purchased": true, "removed_refs": []}`
to stock the pantry.
