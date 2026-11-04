# WG Swiper – mobile app

Expo (SDK 58) + React Native + TypeScript (strict) + Expo Router.

## Run

```
cd apps/mobile
npm install
cp .env.example .env     # fill in values from `supabase status`
npm run dev              # expo start; press i / a, or scan with Expo Go
```

## Scripts

- `npm run dev` – start Metro
- `npm run lint` – ESLint (expo config + prettier)
- `npm run format` – Prettier
- `npm run typecheck` – `tsc --noEmit`
- `npm test` – Jest (jest-expo) + React Native Testing Library

## Layout

- `app/` – Expo Router routes only (`(tabs)`, `(auth)`), thin re-exports
- `src/features/<feature>/` – feature code (screens, hooks)
- `src/lib/` – supabase client, query client, zustand store
- `src/ui/` – theme tokens (light/dark) and shared components
- `src/i18n/` – i18next setup, `de.json` (default) and `en.json`

All UI strings go through `t()`; add keys to both JSON files (a test checks parity).
