# Baray Payment Skill — Cambodia Payment Integration

## What it is

Baray is a Cambodia-only payment API that connects merchants to ABA Bank, ACLEDA, Sathapana, and Wing through a single integration. Uses KHQR (national QR standard) and bank deeplinks.

**This is NOT Stripe.** It's a simple integration service for Cambodian banks.

## Trigger

When a client asks for: payments, checkout, accept money, payment gateway (in Cambodia), KHQR, bank transfer integration.

## What Baray Does

- ✅ Create payment intents → redirect to `pay.baray.io`
- ✅ Receive webhook notifications
- ✅ Support USD and KHR

## What Baray Does NOT Do

- ❌ Subscriptions/recurring payments
- ❌ Refunds
- ❌ Save payment methods
- ❌ Customer management
- ❌ Invoices or payment links
- ❌ Multi-currency conversion
- ❌ Hold funds (banks handle everything)

## The Only Integration Points

```
1. POST /pay  →  Create payment intent (encrypted)
2. Webhook    →  Receive payment confirmation
```

## Flow

1. Merchant encrypts payload (AES-256-CBC with `sk` + `iv`)
2. `POST https://api.baray.io/pay` with encrypted `data` and `x-api-key` header
3. Get `intent_id` back
4. Redirect customer to `https://pay.baray.io/{intent_id}`
5. Customer selects bank, pays in their banking app
6. Baray sends webhook: `{ encrypted_order_id, bank }`
7. Decrypt `encrypted_order_id` with same `sk` + `iv` to get `order_id`
8. Update order status

## Credentials (ALL THREE required)

| Credential | Where to use | Format |
|-----------|-------------|--------|
| `api_key` | HTTP header (`x-api-key`) | String |
| `sk` | Encrypt requests, decrypt webhooks | Base64 (32 bytes) |
| `iv` | Encrypt requests, decrypt webhooks | Base64 (16 bytes) |

Get credentials: `https://dash.baray.io`

## Encryption (AES-256-CBC)

```typescript
import { createCipheriv, createDecipheriv } from "crypto";

function encrypt(payload: object, sk: string, iv: string): string {
  const key = Buffer.from(sk, "base64");
  const ivBuf = Buffer.from(iv, "base64");
  const cipher = createCipheriv("aes-256-cbc", key, ivBuf);
  const encrypted = Buffer.concat([
    cipher.update(JSON.stringify(payload), "utf8"),
    cipher.final(),
  ]);
  return encrypted.toString("base64");
}

function decryptOrderId(encrypted: string, sk: string, iv: string): string {
  const key = Buffer.from(sk, "base64");
  const ivBuf = Buffer.from(iv, "base64");
  const data = Buffer.from(encrypted, "base64");
  const decipher = createDecipheriv("aes-256-cbc", key, ivBuf);
  const decrypted = Buffer.concat([
    decipher.update(data),
    decipher.final(),
  ]);
  return decrypted.toString("utf8");
}
```

## Webhook Handler (Next.js)

```typescript
// app/api/webhooks/baray/route.ts
import { decryptOrderId } from "@/lib/baray";
import { NextRequest, NextResponse } from "next/server";

export async function POST(req: NextRequest) {
  const { encrypted_order_id, bank } = await req.json();

  const orderId = decryptOrderId(
    encrypted_order_id,
    process.env.BARAY_SK!,
    process.env.BARAY_IV!
  );

  // Update order in database
  await updateOrderStatus(orderId, "paid", bank);

  return NextResponse.json({ ok: true });
}
```

## Supported Banks

| Bank | Code | Methods |
|------|------|---------|
| ABA Bank | `aba` | KHQR, Card, Deeplink |
| ACLEDA Bank | `acleda` | KHQR, Deeplink |
| Sathapana Bank | `spn` | KHQR |
| Wing | `wing` | Mobile Wallet |

## Supported Currencies

- USD (min $0.03)
- KHR (min 100)

## Integration Checklist

- [ ] Sign up at https://dash.baray.io
- [ ] Get all 3 credentials: `api_key`, `sk`, `iv`
- [ ] Add encryption/decryption helper to `lib/baray.ts`
- [ ] Create `POST /pay` intent endpoint
- [ ] Add webhook handler at `/api/webhooks/baray`
- [ ] Update order status on webhook
- [ ] Test with DEVELOPMENT keys first

## Full docs

`https://baray.io/llm.txt`
