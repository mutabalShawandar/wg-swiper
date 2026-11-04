# WG Swiper – Project Plan

**Pitch:** "Search who you'd like to live with, not just an apartment."
Tinder-style matching for shared flats (WG) in Germany. People looking for a room and people looking for a flatmate swipe on each other. A mutual like creates a match and opens a chat, so there is no endless texting before a viewing.

## 1. Product

### Roles
- **Seeker** – looking for a room in a WG.
- **Host** – has a room (or a whole WG) and wants a flatmate. A host can be one person or a WG that represents several current flatmates.

### Core loop
1. Onboard: sign up, pick role, build profile (photos, bio, lifestyle tags, budget, city, move-in date).
2. Discover: swipe stack of the opposite role, filtered by city, radius, budget, move-in window, lifestyle.
3. Like / Pass (optional Super-like later).
4. Mutual like → **Match** → in-app chat → propose viewing/video call.
5. Unmatch, block, report at any time.

### Germany-specific
- German + English UI (i18n from day one). Default `de`.
- Cities/PLZ based location, radius search (PostGIS).
- Warmmiete/Kaltmiete, Anmeldung possible (Y/N), furnished, Mietdauer (befristet/unbefristet), WG type (Zweck-WG, Studenten-WG, Berufstätigen-WG, etc.).
- **GDPR/DSGVO**: consent, data export, account deletion, EU region hosting (Supabase Frankfurt), minimal data.
- Age gate 18+. Moderation + report flow (required by App Store / Play).

### MVP scope (in)
Auth, profiles, photo upload, discovery + swipe, matches, realtime chat, push notifications, block/report, account deletion, DE/EN.

### Out of MVP
Payments/premium, video calls, ID verification, listing import, web app, super-like, AI compatibility scoring (v2).

## 2. Tech stack

| Layer | Choice | Why |
|---|---|---|
| Mobile | **Expo (React Native) + TypeScript**, Expo Router | One codebase for iOS + Android, EAS Build/Submit, OTA updates |
| Swipe UI | `react-native-gesture-handler` + `reanimated` | Native-feel gestures |
| State/data | TanStack Query + Zustand | Server cache + light local state |
| i18n | `i18next` + `expo-localization` | DE/EN |
| Backend | **Supabase** (Postgres, Auth, Storage, Realtime, Edge Functions) | |
| Dev backend | Local Supabase via Docker (`supabase start`) | Offline, reproducible, free |
| Prod backend | Supabase Cloud (EU Frankfurt) | Migrations pushed via CLI/CI |
| Geo | PostGIS | Radius queries |
| Push | Expo Notifications + Edge Function triggered by DB webhook | |
| CI/CD | GitHub Actions (lint, typecheck, test, migration check), EAS | |
| Tests | Jest + RNTL (unit), pgTAP (DB/RLS), Maestro (e2e, later) | |

Environments: `local` (Docker) → `prod` (cloud). Optional `staging` cloud project later. The app reads `EXPO_PUBLIC_SUPABASE_URL` / `EXPO_PUBLIC_SUPABASE_ANON_KEY` from env files; never commit secrets.

## 3. Repository layout

```
wg-swiper/
├─ CLAUDE.md
├─ docs/                 # PLAN.md, decisions (ADR), API/db notes
├─ apps/
│  └─ mobile/            # Expo app
│     ├─ app/            # Expo Router screens
│     ├─ src/features/   # auth, profile, discover, matches, chat, settings
│     ├─ src/lib/        # supabase client, i18n, utils
│     └─ src/ui/         # shared components + theme
├─ supabase/
│  ├─ config.toml
│  ├─ migrations/        # timestamped SQL, the only way schema changes
│  ├─ functions/         # edge functions
│  ├─ tests/             # pgTAP
│  └─ seed.sql           # local dev data
├─ packages/
│  └─ shared/            # generated DB types, zod schemas (optional)
└─ .github/workflows/
```

Feature folders keep parallel work from touching the same files.

## 4. Data model (v1 draft)

- `profiles` (id = auth.users.id, role `seeker|host`, display_name, birthdate, bio, gender, languages[], avatar_path, onboarding_done, locale)
- `profile_photos` (profile_id, path, position)
- `lifestyle_tags` / `profile_tags` (smoker, pets, cleanliness, night owl, cooking together, ...)
- `seeker_prefs` (profile_id, city/point, radius_km, budget_min/max, move_in_from/to, stay_months, preferred_wg_types[])
- `listings` (host_id, city, plz, location geography, rent_cold, rent_warm, room_size, furnished, available_from, available_until, wg_size, wg_type, anmeldung, description) + `listing_photos`
- `swipes` (swiper_id, target_id, direction `like|pass`, created_at, unique pair)
- `matches` (user_a, user_b, created_at, unmatched_at) – created by trigger on mutual like
- `messages` (match_id, sender_id, body, created_at, read_at)
- `blocks`, `reports`
- `push_tokens`

**RLS everywhere.** Users read only: own data, discoverable profiles via a `discover` RPC (excludes blocked/swiped/self), matched users' data, their chats. Match creation only via trigger/security-definer function, never client insert.

Key RPCs: `get_discovery_feed(limit, cursor)`, `swipe(target, direction)`, `unmatch(match)`, `delete_account()`.

## 5. Work packages (parallelizable)

Rule: each WP touches its own folder/files. Shared files (root config, `package.json`, navigation root) are touched only in Phase 0.

### Phase 0 – Foundation (do first, sequential, small)
| WP | Branch | Owner area |
|---|---|---|
| 0.1 Repo scaffold, CLAUDE.md, docs, CI skeleton, `.gitignore`, `.env.example` | `chore/repo-scaffold` | root, .github |
| 0.2 Expo app scaffold (TS, Router, i18n, theme, tab shell with empty screens for each feature) | `feat/mobile-scaffold` | apps/mobile |
| 0.3 `supabase init`, local Docker stack, base migration (extensions, profiles), npm scripts `db:start/reset/types` | `feat/supabase-local-setup` | supabase/ |

0.2 and 0.3 are independent and can run as the first pair.

### Phase 1 – Pairs (each pair = 2 agents, no shared files)
| Pair | Agent A (mobile or db) | Agent B | Notes |
|---|---|---|---|
| P1 | **DB: schema + RLS + pgTAP for profiles/prefs/listings/tags** (`feat/db-profiles`) | **Mobile: design system + UI kit + swipe card component with mock data** (`feat/ui-kit-swipe-card`) | Independent |
| P2 | **Auth: supabase client, email + Apple + Google sign-in, session guard** (`feat/mobile-auth`) | **DB: swipes, matches trigger, discovery RPC, blocks/reports + pgTAP** (`feat/db-swipes-matches`) | Auth needs only `auth.users`; DB needs only P1 profiles |
| P3 | **Mobile: onboarding + profile edit + photo upload** (`feat/mobile-profile`) | **DB/Storage: buckets, storage policies, image rules, seed data** (`feat/storage-seed`) | |
| P4 | **Mobile: discover screen wired to RPC, filters** (`feat/mobile-discover`) | **Mobile: matches list + realtime chat UI** (`feat/mobile-chat`) | Different feature folders |
| P5 | **Push: tokens table, edge function, Expo notifications client** (`feat/push`) | **Settings: language, block list, report, account deletion + data export** (`feat/settings-gdpr`) | |
| P6 | **CI/CD: GH Actions, EAS profiles, migration deploy to cloud** (`chore/ci-cd`) | **Moderation/hardening: rate limits, RLS audit, advisors check** (`chore/security-audit`) | |
| P7 | **Store prep: icons, splash, privacy policy, store listings, TestFlight/Play internal** | **E2E smoke tests (Maestro) + bugfix sweep** | Release candidate |

Contract between mobile and DB agents: DB agent finishes by regenerating types (`supabase gen types`) and documenting RPC signatures in `docs/api.md`; mobile agent codes against that doc and mocks until the DB branch is merged.

### Phase 2 – Post-MVP ideas
Super-like, verification badge, compatibility score, WG-group profiles with multiple members, video intro, premium, web landing page.

## 6. Milestones
1. M0 Foundation merged (scaffold + local Supabase running)
2. M1 Sign in, profile, photos
3. M2 Swipe + match
4. M3 Chat + push
5. M4 GDPR/safety + CI/CD
6. M5 TestFlight / Play internal testing → launch

## 7. Risks
- **App Store rules** for dating/UGC apps: reporting, blocking, moderation, 18+, account deletion are mandatory – built into MVP.
- **Cold start / liquidity**: launch in one city first (e.g. Berlin or Munich).
- **Photo moderation**: start with report-based moderation; consider automated checks later.
- **Apple Sign-In** is required if any other social login is offered.
