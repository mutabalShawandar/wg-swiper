---
title: Mobile app scaffold (Expo + Router + i18n + theme)
type: feature
branch: feat/mobile-scaffold
pr: https://github.com/mutabalShawandar/wg-swiper/pull/4
status: done
date: 2026-11-04
---
## What was built (and where: file paths)
- `apps/mobile/` Expo SDK 58 app, self-contained (own package.json, no root package.json).
- Routes: `app/_layout.tsx` (providers: i18n, TanStack Query), `app/index.tsx` (redirects to `/discover`), `app/(tabs)/{discover,matches,chat,profile,settings}.tsx` + `_layout.tsx`, `app/(auth)/sign-in.tsx` placeholder.
- `src/features/<feature>/<Feature>Screen.tsx` placeholders; `src/features/auth/` empty.
- `src/lib/supabase.ts`, `queryClient.ts`, `appStore.ts` (zustand stub).
- `src/ui/theme.ts` (`useTheme()`, palette light/dark, spacing, typography), `src/ui/PlaceholderScreen.tsx`.
- `src/i18n/{index.ts,de.json,en.json}`.
- Tests in `apps/mobile/__tests__/` (one smoke test per tab, i18n key-parity test).

## How to use it (commands, imports, conventions, examples)
- `cd apps/mobile && npm install && cp .env.example .env && npm run dev`.
- Scripts: `dev`, `lint`, `format`, `typecheck`, `test`.
- Import alias `@/` maps to `src/` (tsconfig paths + babel via expo preset; jest moduleNameMapper).
- Route files in `app/` stay thin and re-export a screen from `src/features`.
- Strings: `const { t } = useTranslation(); t('tabs.discover')`.
- Theme: `const { colors, spacing, typography } = useTheme()`.

## Decisions and why (versions chosen, alternatives rejected)
- Versions are those `create-expo-app` / `expo install` resolved on 2026-11-04 (Expo ~58, RN 0.88, React 19.3, TS 6); see package.json.
- Device language `en` selects English, anything else falls back to German (product default).
- Supabase client uses AsyncStorage for session persistence; secure-store may replace it in the auth task.
- No root workspace: CLAUDE.md forbids shared root file edits for this task.

## Contracts other agents depend on (env vars, folder structure, exported APIs, i18n key conventions)
- Env: `EXPO_PUBLIC_SUPABASE_URL`, `EXPO_PUBLIC_SUPABASE_ANON_KEY` (throws on import of `@/lib/supabase` if missing).
- Exports: `supabase`, `queryClient`, `useAppStore`, `useTheme`, `PlaceholderScreen`, default `i18n`.
- i18n keys: namespaced by feature (`tabs.*`, `common.*`, `auth.*`); add to both `de.json` and `en.json`.
- Tab route names: discover, matches, chat, profile, settings.

## Not done / known gaps / unverified (be honest, e.g. no simulator run)
- App was NOT run on a simulator, emulator, or device; only lint, typecheck and jest were run.
- No auth guard; `app/index.tsx` redirects straight to tabs.
- Default Expo placeholder icons/splash are used.
- No language switcher yet (settings task).
- Supabase client is not covered by tests (needs env).

## Notes for other agents (what to reuse, what NOT to rebuild)
- Reuse the theme and i18n setup; do not add a second provider setup.
- Importing `@/lib/supabase` in tests needs the env vars mocked.
- Use `git add` carefully: `apps/mobile/.claude/` is gitignored.
