---
title: Supabase local setup, base profiles migration, RLS test
type: feature
branch: feat/supabase-local-setup
pr: https://github.com/mutabalShawandar/wg-swiper/pull/3
status: done
date: 2026-11-04
---
## What was built (and where: file paths)
- `supabase/config.toml` (project_id `wg-swiper`, password min 8, email signup on, confirmations off locally)
- `supabase/migrations/20261104093724_base_profiles.sql`: postgis (schema `extensions`), enum `user_role`, table `profiles`, RLS + policies, `set_updated_at` trigger, security definer `handle_new_user` + trigger on `auth.users`
- `supabase/seed.sql` (dev-only, effectively empty), `supabase/tests/profiles_rls.test.sql` (pgTAP, 11 assertions)
- Root `package.json` scripts `db:start|stop|reset|types|test`, `supabase` devDependency
- `docs/local-dev.md`, `docs/api.md`

## How to use it (commands, ports, how to start/reset/test/gen types, examples)
`npm install`, then `npm run db:start`, `db:reset`, `db:test`, `db:types`, `db:stop`. Ports: API 54321, DB 54322, Studio 54323, Mailpit 54324. Details in `docs/local-dev.md`.

## Decisions and why (config choices, alternatives rejected)
- birthdate/display_name nullable: the row is created at signup, collected in onboarding. 18+ enforced by CHECK.
- No delete grant to clients; account deletion via auth cascade / future security definer RPC.
- `auth.uid()` wrapped in `(select ...)` for planner caching.
- Confirmations off locally (Mailpit exists anyway); turn on for prod.

## Contracts other agents depend on (tables, enums, RPCs, RLS rules, type file location, migration naming)
See `docs/api.md`. Migrations named `YYYYMMDDHHMMSS_name.sql` via `supabase migration new`. Type file: `packages/shared/db-types.ts` (NOT generated yet, see below).

## Not done / known gaps / unverified (be honest, include the verified local MCP findings)
- The Docker daemon on the authoring machine returned HTTP 500 intermittently and image pulls timed out, so `supabase start` never completed.
- UNVERIFIED (never executed): the migration SQL, the pgTAP test, `supabase db reset`, `supabase test db`, `supabase db lint`, advisors.
- `packages/shared/db-types.ts` not generated. Run `npm run db:types` once the stack runs.
- Local MCP (`http://localhost:54321/mcp`): NOT verified, no findings.
- Loopback network option is documented, not tested.

## Notes for other agents (what to reuse, what NOT to rebuild, pitfalls, one-stack-per-machine rules)
- Run `db:reset` and `db:test` first and fix any SQL errors before building on this.
- One local stack per machine (fixed ports); do not reset while others use it.
- Do not commit keys from `supabase status`.
