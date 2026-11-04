# Local development (Supabase)

Requires Docker Desktop and Node. The CLI is a devDependency (`npx supabase`).

## Commands (repo root)
| Script | Does |
|---|---|
| `npm run db:start` | `supabase start` (first run pulls many images, can take 10+ min) |
| `npm run db:stop` | `supabase stop` |
| `npm run db:reset` | recreate DB, apply migrations + `supabase/seed.sql` |
| `npm run db:test` | run pgTAP tests in `supabase/tests` |
| `npm run db:types` | regenerate `packages/shared/db-types.ts` |

New migration: `npx supabase migration new <name>`. Lint: `npx supabase db lint`.

## Ports (config.toml defaults)
API 54321, DB 54322, Studio 54323, Mailpit (inbucket) 54324. Project id `wg-swiper`.

## One stack per machine
Ports are fixed, so only one local stack can run. Parallel worktrees share it; do not run `db reset` while another task uses it. Only DB tasks start/stop the stack.

## Keys
Run `npx supabase status` for the URL and anon/service keys. They are well-known local demo keys but are not committed. Put them in an untracked `.env` as `EXPO_PUBLIC_SUPABASE_URL` / `EXPO_PUBLIC_SUPABASE_ANON_KEY`. The service-role key never goes into the app.

## Loopback-only network (untrusted networks)
```
docker network create -o 'com.docker.network.bridge.host_binding_ipv4=127.0.0.1' local-network
npx supabase start --network-id local-network
```

## Auth config
Email signup on, confirmations off locally (mail goes to Mailpit anyway), password min 8, JWT expiry 3600 (default). Apple/social providers disabled until configured with env secrets.

## Local MCP
UNVERIFIED: the local stack could not be started on the authoring machine (Docker daemon returned HTTP 500 and image pulls timed out), so `http://localhost:54321/mcp` behavior (auth, tools) has not been checked. Per docs/PLAN.md it is expected at that URL; verify with `curl -i http://localhost:54321/mcp` after `db:start` and update this section.
