# CLAUDE.md – WG Swiper

Tinder-style app for shared flats (WG) in Germany: seekers and hosts swipe, mutual like = match + chat. iOS + Android. Full plan: `docs/PLAN.md` (read it before starting any task).

## Stack
- Mobile: Expo (React Native) + TypeScript + Expo Router, in `apps/mobile`
- Backend: Supabase. **Local via Docker for dev** (`supabase start`), **Supabase Cloud (EU) for prod**
- DB changes only through SQL migrations in `supabase/migrations`. Never edit the cloud schema by hand.
- i18n: German (default) + English. No hardcoded UI strings.

## Git & GitHub rules
- Before any `git push` or `gh` command run `gh auth switch --user mutabalShawandar` and confirm with `gh auth status`. Commit with that account's identity (set repo-local `user.name`/`user.email`, never global).
- `main` is always working. **Never commit directly to `main`.** Everything lands via a branch merge.
- Branch names: `feat/…`, `fix/…`, `chore/…`, `docs/…`, `test/…`.
- Every task = one branch = one git worktree at `../wg-swiper-worktrees/<branch-name-with-dashes>`.
  ```
  git worktree add ../wg-swiper-worktrees/feat-mobile-auth -b feat/mobile-auth main
  ```
- Commits: small, focused, Conventional Commits (`feat(auth): add Apple sign-in`). Commit often, never lump unrelated changes. Never skip hooks, never force-push `main`.
- Merge into `main` with a PR (`gh pr create`) and squash or rebase merge; rebase on `main` first and resolve conflicts in the branch. Delete branch and remove worktree after merge (`git worktree remove`).
- Never commit secrets, `.env*` (except `.env.example`), service-role keys, or generated build output.
- Public repo: assume everything committed is world-readable.

## Parallel work protocol
When the user says "work on X" / names tasks:
1. Pick (or confirm) **two tasks that do not depend on each other** and touch **different files/folders** (see work packages in `docs/PLAN.md`). If they conflict or depend on each other, say so and propose a different pairing.
2. Spawn **2 agents**, each with `isolation: "worktree"` on its own branch. Give each a self-contained prompt: goal, branch name, allowed folders, acceptance criteria, and these rules.
3. Agents work only inside their own worktree and allowed folders. They must not edit shared root files (root `package.json`, CI, navigation root, `CLAUDE.md`) unless the task is explicitly about them. If they need such a change, report it instead.
4. Each agent finishes with: lint + typecheck + tests green, committed, pushed, PR opened against `main`.
5. The orchestrating session reviews both PRs, merges them to `main` one at a time (rebase the second on the updated `main`), runs checks on `main`, then cleans up worktrees/branches.
6. DB ↔ mobile contract: DB tasks end by regenerating types and documenting RPC signatures in `docs/api.md`; mobile tasks code against that doc.

## Supabase workflow
- Start local stack: `supabase start` (Docker must be running). Reset with seed: `supabase db reset`.
- Create migration: `supabase migration new <name>`; keep migrations small, idempotent-safe, and forward-only.
- After schema changes: `supabase gen types typescript --local > packages/shared/db-types.ts`.
- **Every table has RLS enabled** with explicit policies. Match creation, deletion of accounts, and other privileged actions go through `security definer` functions with `set search_path = ''`.
- Add pgTAP tests in `supabase/tests` for every policy and RPC.
- Prod: migrations are pushed with `supabase db push` (via CI) only from `main`. Never run destructive SQL against prod from a dev machine.
- Env: local keys come from `supabase status`; app config via `EXPO_PUBLIC_SUPABASE_URL` / `EXPO_PUBLIC_SUPABASE_ANON_KEY`. The service-role key is never shipped in the app.

## Code conventions
- TypeScript strict; no `any` without a comment explaining why.
- Feature-folder structure: `apps/mobile/src/features/<feature>/…`. Features don't import each other's internals; share via `src/ui` or `src/lib`.
- Data access through TanStack Query hooks per feature; no raw Supabase calls inside components.
- Validate external input with zod. Handle loading, empty, and error states in every screen.
- Accessibility: labels on touchables, dynamic type, sufficient contrast, swipe actions also available as buttons.
- Keep files small and focused; match existing style; run formatter (Prettier) and ESLint before committing.
- Comments explain *why*, not *what*.

## Product guardrails (non-negotiable)
- 18+ only; block, report, unmatch, and account deletion must always work (App Store / Play requirement).
- GDPR: collect minimal data, explicit consent, data export + deletion, EU hosting.
- Never expose another user's exact location, birthdate, or email; show city/district and age only.
- Sign in with Apple must exist if any other social login exists.

## Definition of done
Lint, typecheck, unit tests, and pgTAP tests pass; DE and EN strings present; RLS verified for any new table; docs updated (`docs/api.md` or PLAN); PR description says what changed and how to test.

## Useful commands (fill in as scaffolding lands)
```
npm run dev:mobile      # expo start
npm run db:start        # supabase start
npm run db:reset        # supabase db reset
npm run db:types        # regenerate TS types
npm run lint && npm run typecheck && npm test
```
