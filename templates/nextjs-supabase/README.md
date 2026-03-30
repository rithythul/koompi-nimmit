# KOOMPI Next.js + Supabase Starter

Production-ready Next.js 16 + Supabase starter template with Khmer language support.

## Features

- **Next.js 16** with App Router and Turbopack
- **Supabase** for auth, database, and storage
- **TypeScript** strict mode
- **Tailwind CSS v4** + shadcn/ui components
- **Khmer font** (NotoSansKhmer) via Google Fonts
- **Magic link auth** out of the box
- **RLS policies** on all tables
- **Mobile-first** responsive design
- **Vercel-ready** deployment

## Getting Started

1. Clone and install:
   ```bash
   bun install
   ```

2. Set up environment:
   ```bash
   cp .env.example .env.local
   ```
   Fill in your Supabase project URL and anon key.

3. Run the migration in your Supabase dashboard (SQL Editor) or via CLI:
   ```bash
   supabase db push
   ```

4. Start development:
   ```bash
   bun dev
   ```

## Project Structure

```
src/
├── app/              — App Router pages and layouts
│   ├── (auth)/       — Auth pages (login, callback)
│   ├── (protected)/  — Authenticated pages (dashboard)
│   └── api/          — API routes
├── components/       — React components
│   └── ui/           — shadcn/ui components
└── lib/              — Utilities and Supabase clients
    └── supabase/     — Server and browser Supabase clients
```

## Deployment

Deploy to Vercel with one click. The `vercel.json` is pre-configured.

Set these environment variables in your Vercel project:
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
