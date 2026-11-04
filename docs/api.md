# API / DB contract

Generated types: `packages/shared/db-types.ts` (regenerate with `npm run db:types`).

## Tables

### `public.profiles`
One row per auth user, created automatically by trigger `on_auth_user_created` (`public.handle_new_user`, security definer).

| Column | Type | Notes |
|---|---|---|
| id | uuid PK | = `auth.users.id`, cascades on delete |
| role | `user_role` (`seeker`\|`host`) | default `seeker` |
| display_name | text | 1-50 chars, nullable until onboarding |
| birthdate | date | nullable until onboarding; CHECK 18+ |
| bio | text | max 500 |
| locale | text | `de` (default) or `en` |
| onboarding_done | boolean | default false |
| created_at / updated_at | timestamptz | `updated_at` maintained by trigger |

RLS (authenticated only; `anon` has no access): select/insert/update own row only (`id = auth.uid()`); no client delete. Never expose another user's birthdate; future public views must show age only.

## RPCs
None yet.
