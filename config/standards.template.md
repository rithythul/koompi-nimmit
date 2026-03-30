# STANDARDS.md — Code Quality Bar

## TypeScript

- **Strict mode always.** No `any`, no `// @ts-ignore`
- Use `interface` over `type` for object shapes
- Use `const` over `let` — never `var`
- Destructure imports and function params
- Named exports only — no default exports
- Async/await — no raw `.then()` chains

## React / Next.js

- Server Components by default — Client Components only when needed
- App Router only — no Pages Router
- Tailwind CSS for styling — no CSS modules or styled-components
- `shadcn/ui` for UI components
- Colocation: components near their pages, utils in `lib/`

## Database (Supabase)

- Always use typed queries (`supabase.from<T>('table')`)
- Row Level Security (RLS) on every table
- Migrations for all schema changes — never edit production directly
- Seed files for development data

## Git

- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`
- Branch: `main` is protected — PRs only
- Small, focused commits — one concern per commit

## API Design

- REST by default — GraphQL only when explicitly requested
- Consistent error responses: `{ error: string, code: string }`
- Input validation on every endpoint
- OpenAPI spec for public APIs

## General

- No hardcoded values — use environment variables
- No `console.log` in production — use structured logging
- No secrets in code or commits
- Lint before commit
