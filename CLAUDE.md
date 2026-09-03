# CLAUDE.md

## What this is

`prototype_1` — a **UI-only Flutter prototype** of the KBZ Life **Agent App** (mobile, iOS + Android). It implements the screens and flows from the BRD (`15052026 - Agent App Business Requirement Document.pdf`) and the approved HTML/Tailwind mockups in `KBZ Mobile ProtoType 1/`.

**There is no backend.** Every "API call" is a `Future.delayed` against fixed fixtures in `lib/data/mock/`. Do not add real networking, auth, or persistence unless explicitly asked — `dio`, `flutter_secure_storage`, and `shared_preferences` are declared in `pubspec.yaml` for the eventual real build but are largely unused today.

## Commands

```bash
flutter run
```
```bash
flutter analyze
```
```bash
flutter test
```

After changing `assets/brand-mark.png` or the splash lockup: `dart run flutter_launcher_icons` / `dart run flutter_native_splash:create`.

## Architecture

- **State**: Riverpod (`flutter_riverpod`), `StateNotifierProvider` throughout. Providers live beside their feature (`lib/features/<area>/<area>_providers.dart`), not in a global folder.
- **Routing**: `go_router`, single `appRouterProvider` in [app_router.dart](lib/core/router/app_router.dart). All routes are declared there — add new screens to that list rather than pushing `MaterialPageRoute`.
  - `StatefulShellRoute.indexedStack` drives the 4-tab bottom nav (`/home`, `/tasks`, `/notifications`, `/profile`) via `HomeShell`.
  - Guest-first: `_publicPaths` + `_isPublic()` define what works logged-out (products, quote calculator, resources, announcements, all auth screens). Logged-out users hitting a private path land on `/guest`, and in-screen gated actions open the shared `LoginRequiredSheet` rather than hard-redirecting.
  - `/splash` is exempt from redirect — `AnimatedSplashScreen` picks its own destination after its animation.
- **Layers**: `lib/core/` (theme, router, shared widgets, utils) → `lib/data/` (immutable models + mock fixtures) → `lib/features/<area>/` (screens, controllers, feature widgets). Features may import core and data; core must not import features.

## Conventions

- **Theme is light-only.** Colors come from `AppColors` and radii from `AppRadii` ([app_colors.dart](lib/core/theme/app_colors.dart), [app_theme.dart](lib/core/theme/app_theme.dart)) — never hardcode a `Color(0x...)` in a screen. The core visual relationship is grey canvas (`AppColors.cream`) + raised white cards (`AppColors.paper`), so use `SoftCard` rather than rolling a new `Container` + shadow.
- **Reuse the core widgets** before writing new ones: `SoftCard`, `AppTextField`, `AppSelectionChip`, `LoginRequiredSheet`, `PasswordStrengthChecklist`, `QuoteFieldRenderer`, `AppBottomNavItem/Action`.
- **Dates/times go through `AppDate`** ([app_date.dart](lib/core/utils/app_date.dart)): `dd-MMM-yyyy`, English months regardless of locale, 12-hour padded clock. Never call `DateFormat` directly in a screen.
- **Typography**: DM Sans via `google_fonts`, configured centrally in `AppTheme`.
- **Comments carry the "why"**, and they cite their source — BRD clauses (`FR-01 §3.4`), or a numbered design doc (`Doc 94`). Match that: when a layout choice looks odd, it is usually pinned to a doc, so read the referenced file before "fixing" it.
- Roles are `AgentRole { fa, am, sam, dm, aadm, adm, sadm, radm, hoa, superAdmin }` — dashboards and Team screens branch on FA vs. manager tiers.

## e-App wizard (`lib/features/eapp/`)

The largest feature, and the one pinned hardest to source documents. Its field list comes from the
BRD workbook's **Proposal (Required Field)** sheet and its error strings from the **Proposal
Validation Message** sheet — quote the message verbatim rather than inventing one.

- Steps are `_EStep` in [eapp_screen.dart](lib/features/eapp/eapp_screen.dart): Proposal → Policy
  Holder → Insured Person → Product Information → Beneficiaries → (Health Declaration, health
  products only) → Documentation → Sign → Review. Each has an entry in `_canContinue`.
- **One applicant model** ([applicant.dart](lib/features/eapp/applicant.dart)) covers all three
  parties × Person/Entity; `ApplicantCard` is the single renderer and branches on
  `role` × `type`. Never fork a second copy of these fields for one party.
- **Validators live in `ApplicantValidators`**, never inline in a screen — that is what keeps the
  three party cards from drifting.
- **Long forms fold, they do not sprawl** (doc 111, doc 114): system-filled values render as `_Row`
  read-outs, conditional fields are absent until their condition is true, and optional fields sit
  inside `OptionalDetails` with a filled-count in the header. Address collapses to one row that
  opens a sub-sheet, where picking a Town auto-fills Township / District / State-Region from
  `kTownMaster` ([address_master.dart](lib/features/eapp/address_master.dart)).

## Mock data you'll need

In [auth_providers.dart](lib/features/auth/auth_providers.dart):
- OTP is always `123456` (`kMockOtp`); any other 6-digit code fails so the retry loop can be demoed.
- Phones "known to Core": `09420000001`, `09765432100`, `09123456789` (`kMockCorePhones`). Login with a password under 4 chars fails (5 failures → lockout); `09123456789` triggers the one-shot concurrent-session dialog.

## Docs

`docs/` holds ~115 numbered UX decision records (`docs/NN-topic.md`) plus per-FR plans and brainstorms. They are the source of truth for screen behaviour and the running log of why the UI looks the way it does. When making a non-trivial UX change, check for an existing numbered doc on that screen first; the project convention is to add a new numbered doc for a new decision.
