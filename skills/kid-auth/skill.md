# KID Auth Skill — KOOMPI ID (OAuth 2.0 + Wallet)

## What it is

KOOMPI ID (KID) is a sovereign identity service with OAuth 2.0, blockchain wallet integration, and token management. Use this to add "Login with KID" to any webapp.

## Trigger

When a client asks for: user authentication, login system, user accounts, identity verification, wallet integration.

## API Reference

Base URL: `https://oauth.koompi.org`
SDK: `npm install @koompi/oauth`
Dashboard: `https://dash.koompi.org`

### Flow

1. **Redirect to KID login:**
   ```
   GET https://oauth.koompi.org/v2/oauth
     ?client_id=YOUR_CLIENT_ID
     &redirect_uri=https://yourapp.com/callback
     &scope=profile.basic wallet.transfer
     &state=RANDOM_CSRF_TOKEN
   ```

2. **Exchange code for tokens + user info (single call):**
   ```
   POST https://oauth.koompi.org/v2/oauth/token
   { grant_type, code, client_id, client_secret, redirect_uri }
   ```
   Response includes: `access_token`, `refresh_token`, `user` object.

3. **Get user info (optional):**
   ```
   GET https://oauth.koompi.org/v2/oauth/userinfo
   Authorization: Bearer <access_token>
   ```

### Scopes

| Scope | Access |
|-------|--------|
| `profile.basic` | id, fullname, username, avatar |
| `profile.contact` | email, phone, telegram_id |
| `wallet.read` | wallet_address |
| `wallet.transfer` | ERC20 transfers on user's behalf |
| `wallet.balance` | Token balances |

### SDK Usage

```typescript
import { KoompiAuth } from "@koompi/oauth";

// Frontend
const auth = new KoompiAuth({
  clientId: "YOUR_CLIENT_ID",
  redirectUri: "https://yourapp.com/callback",
});
const loginUrl = await auth.createLoginUrl({ scope: ["profile.basic"] });
window.location.href = loginUrl;

// Backend
const auth = new KoompiAuth({
  clientId: "YOUR_CLIENT_ID",
  clientSecret: "YOUR_CLIENT_SECRET",
  redirectUri: "https://yourapp.com/callback",
});
const tokens = await auth.exchangeCode({ code });
const user = await auth.getUserInfo(tokens.access_token);
```

## Integration with Next.js Template

1. Add `@koompi/oauth` to package.json
2. Create `/api/auth/kid/callback/route.ts` — exchanges code for tokens
3. Create `/api/auth/kid/signout/route.ts` — clears session
4. Update login page with "Login with KID" button
5. Create middleware to refresh tokens

## Credentials

Client needs: `client_id` and `client_secret` from https://dash.koompi.org

## Full docs

`https://dash.koompi.org/llms.txt`
