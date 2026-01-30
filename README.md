# NovaCommerce

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![State](https://img.shields.io/badge/State-Riverpod-3C873A)
![Routing](https://img.shields.io/badge/Routing-GoRouter-6E56CF)
![Backend](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=000)
![DB](https://img.shields.io/badge/DB-Firestore-FFA000?logo=firebase&logoColor=000)
![AI](https://img.shields.io/badge/AI-TFLite%20(on--device)-FF6F00?logo=tensorflow&logoColor=white)

A Flutter + Firebase commerce app showcasing an end‑to‑end shopping loop with a clean, scalable architecture: **storefront browsing → product details (variants) → cart → checkout (shipping form) → orders**, plus a modular “AI layer” (chat placeholder) and an **on‑device TFLite navigation intent model**.

> **Scope / Intentional omissions:** Payments, carrier/logistics integrations, and admin tooling are intentionally out of scope for the current MVP.

---

## Contents

- [Current status](#current-status)
- [Features](#features)
- [Screenshots](#screenshots)
- [AI](#ai)
- [UI / UX notes](#ui--ux-notes)
- [Tech stack](#tech-stack)
- [Project structure](#project-structure)
- [Getting started](#getting-started)
- [Configuration & feature flags](#configuration--feature-flags)
- [Firebase setup](#firebase-setup)
- [Emulators](#emulators)
- [Demo mode](#demo-mode)
- [Testing](#testing)
- [Known limitations](#known-limitations)
- [Roadmap ideas](#roadmap-ideas)
- [License](#license)

---

## Current status

### Fully implemented and stable

- **Core browsing loop**
  - Home feed loads products and supports **pull‑to‑refresh** + **infinite scroll** (pagination / “load more”).
  - Product grid navigation into product details is stable.
- **Cart**
  - Cart persists locally and **syncs to Firestore when signed in** (falls back to local storage when signed out).
  - Quantity management + selection behavior (used by checkout summary) is in place.
- **Checkout**
  - Shipping form flow is implemented (manual entry).
  - Order placement is implemented via a **Firestore transaction** that decrements variant stock and creates an order document.
- **Orders**
  - Orders list + order details exist (Firestore-backed when not using fake repos).
- **Auth**
  - Anonymous (guest) sessions supported.
  - Email/password sign‑in supported.
  - Google sign‑in supported.
  - Guest → signed‑in upgrade path exists at the UX level (sign‑in entry points are present).
- **Wishlist**
  - Implemented using **SharedPreferences** (local persistence).
- **Recently viewed**
  - Implemented using **SharedPreferences** (local persistence).
- **AI assistant (optional)**
  - Present as a feature/screen and currently backed by a **fake repository implementation** (deterministic placeholder behavior).

### Partially implemented / placeholder

- **AI chat**
  - Uses `FakeAiRepository` (no production inference service wired).
  - “AI placeholder” env flags exist in `AppEnv`, but they’re disabled by default.
- **Places autocomplete (checkout)**
  - Optional integration exists behind `AppEnv.enablePlacesAutocomplete` and requires `GOOGLE_PLACES_API_KEY`.
  - When not configured, checkout works in manual entry mode.
- **“Nova UI” components**
  - Parallel UI system (`NovaAppBar`, `NovaButton`, `NovaSurface`, …) gated behind `AppEnv.enableNovaUi` + per‑screen flags.
  - Default behavior is still mostly standard Material widgets unless flags are enabled.

### Intentionally not implemented yet

- **Payments:** no Stripe/PayPal, no real authorization/capture flow.
- **Shipping/logistics integrations:** no carrier rates, tracking, fulfillment pipeline.
- **Admin tooling:** no admin dashboard, inventory management UI, or order management UI.
- **Personalization on Home:** Home is storefront-style, not personalized (even though flags exist for experimentation).
- **Trusted server-side checkout:** the repo currently has **no Cloud Functions backend** committed (`functions/` exists but is empty). Checkout is **client → Firestore transaction**, not a trusted server.

---

## Features

### Home page (storefront feed)

- **AppBar**
  - Title: **Nova**
  - Actions: Messages (`/messages`), Sign in (`/signIn`), Wishlist (`/wishlist`), Cart (`/cart`)
  - Cart navigation is guarded to prevent double navigation.
- **Feed container**
  - `CustomScrollView` with slivers
  - Pull‑to‑refresh via `RefreshIndicator`
  - Pagination triggers `loadMore()` near the bottom
  - Light “scroll hint” auto‑scroll nudge on first load
  - Image precache for the first ~4 product images
- **Sections (Home v1 storefront)**
  - AI entry card (navigates to AI screen; can auto‑send a prompt)
  - “Trending drop” hero card (scroll-to-section)
  - “Browse” section with search / filter / sort MVP UI
  - Multiple product sections derived from the loaded list (e.g. trending, picked, “under $50” style selection via local rules)

### Product browsing

- Firestore-backed product repository (when not in fake mode).
- Pagination / load-more behavior supported through the Home viewmodel flow.

### Product details

- Product details screen exists.
- Variant selection (size/color) integrates with cart selection.
- “View cart” snackbar action includes guard logic to avoid crashes/double taps.

### Cart

- Local persistence via a SharedPreferences-backed repository.
- When signed in, a syncing repository bridges local cart and Firestore.
- Remote cart stored in Firestore under `carts/<uid>` with an `items` array (via datasource/repository structure).

### Checkout

- Shipping form fields:
  - full name, phone, address, city/state/postal/country
- Phone normalization:
  - special handling for **LB** + general normalization via `phone_number`
- Optional **Places** autocomplete behind env flags (manual entry always available).
- Checkout summary uses **selected cart items**:
  - Subtotal derived from selected items
  - Shipping fee currently **0.0** (constant)
  - Total = subtotal + shippingFee
- Submit calls `OrderRepository.placeOrder(...)` and navigates to a success screen.

### Orders

- Firestore-backed reads (list + fetch-by-id).
- Order writes include (at minimum):
  - `uid`, `deviceId`, `status`, totals, `shipping` map, `items` array, timestamps.

### Wishlist

- Local wishlist persistence via SharedPreferences.
- Wishlist UI includes empty state + populated state.

### Search

- Search UI exists as part of the Home “Browse” section (and route navigation exists).
- MVP-level search/filtering (not a dedicated search backend).

### Profile

- Profile screen exists.
- Profile details screens exist (some gated behind Nova UI flags).

### Auth (guest / signed-in)

- Firebase Auth providers:
  - Anonymous auth
  - Email/password
  - Google sign‑in
- App supports signed‑out/guest browsing and cart usage.
- **Checkout requires sign‑in.**

### Recently viewed

- SharedPreferences-backed repository + feature exists.

---

## Screenshots

<!-- 4-column grid using HTML (renders well on GitHub) -->
<div align="center">
  <img src="assets/screenshots/Img1.jpeg" width="22%" alt="Home" />
  <img src="assets/screenshots/Img2.jpeg" width="22%" alt="Home feed" />
  <img src="assets/screenshots/Img3.jpeg" width="22%" alt="Product details" />
  <img src="assets/screenshots/Img4.jpeg" width="22%" alt="Out of stock item" />
  <img src="assets/screenshots/Img5.jpeg" width="22%" alt="Nova AI" />
  <img src="assets/screenshots/Img6.jpeg" width="22%" alt="Trends" />
</div>

<br/>

<div align="center">
  <img src="assets/screenshots/Img7.jpeg" width="22%" alt="Cart" />
  <img src="assets/screenshots/Img8.jpeg" width="22%" alt="Cart is empty" />
  <img src="assets/screenshots/Img9.jpeg" width="22%" alt="Checkout" />
  <img src="assets/screenshots/Img10.jpeg" width="22%" alt="Profile" />
  <img src="assets/screenshots/Img11.jpeg" width="22%" alt="Wishlist empty" />
</div>

<br/>

<div align="center">
  <img src="assets/screenshots/Img12.jpeg" width="22%" alt="Wishlist with item" />
  <img src="assets/screenshots/Img13.jpeg" width="22%" alt="Orders" />
  <img src="assets/screenshots/Img14.jpeg" width="22%" alt="Sign in" />
  <img src="assets/screenshots/Img15.jpeg" width="22%" alt="Messages" />
</div>

---

## AI

NovaCommerce currently contains **two separate “AI-ish” surfaces**:

1) **On-device navigation intent classifier** (real on-device model)  
2) **“Nova AI” chat assistant screen** (placeholder, fake repo)

### 1) AI navigation intent model: `ai_nav_model_quant.tflite`

**What it is**
- An **on-device TensorFlow Lite** model (quantized) used for lightweight classification.
- Purpose: predict a navigation intent (“where the user likely wants to go next”).

**Outputs (6 classes)**
The model outputs 6 probabilities mapped to:

```dart
enum AiNavIntent { home, ai, trends, cart, profile, idle }
```

**Inputs (5 numeric features)**
The model expects **exactly 5 float features**, built from app signals:

- `f0`: normalized current tab index (0..1)
- `f1`: normalized cart count (`cartCount / 20`, clamped 0..1)
- `f2`: normalized wishlist count (`wishlistCount / 50`, clamped 0..1)
- `f3`: signed-in flag (1.0 if signed in, else 0.0)
- `f4`: normalized hour-of-day (`hour / 23`, clamped 0..1)

**How it runs**
- Asset: `assets/models/ai_nav_model_quant.tflite`
- Loaded via `rootBundle.load(...)`
- Inference via `tflite_flutter` `Interpreter` (`Interpreter.fromBuffer(...)`)
- Shapes:
  - Input: `[[f0, f1, f2, f3, f4]]` (batch size 1)
  - Output: `1 x 6` probability vector
- The app:
  - normalizes probabilities (guarding against numeric drift),
  - picks argmax as intent,
  - exposes intent, confidence, and the full vector.

**Safety rails**
`AiNavController` adds guard logic:
- never triggers on `idle`
- minimum confidence threshold (default `minConfidence = 0.35`)
- minimum margin vs runner-up (default `minMargin = 0.10`)
- stability requirement:
  - either high confidence (`>= 0.60`) **or**
  - the same intent predicted consecutively (default 2 times)
- cooldown after a suggestion is consumed (~800ms)
- fail-safe: if the model can’t load (common in some test envs), it emits **no suggestion** (no crash).

**Where it’s wired**
A Riverpod provider creates:
- `AiNavModelRunner(assetPath: 'assets/models/ai_nav_model_quant.tflite')`
- `AiNavController(modelRunner: runner)`

UI can listen to the controller state and display smart navigation suggestions.

### 2) Nova AI chat assistant (placeholder)

- The chat assistant screen exists as a feature route.
- It is currently backed by a **fake/deterministic** repository (`FakeAiRepository`).
- No production inference endpoint is wired in the repo state.

---

## UI / UX notes

### Home v1 direction

- Home is a **storefront feed** (not personalized).
- Predictable sections + responsive grids.
- Lightweight UX polish (prefetch + small scroll hint); no heavy animations.

### ProductCard behavior

From `lib/core/widgets/product_card.dart`:
- Image uses `BoxFit.cover` (cropped to fill).
- Uses `memCacheWidth` / `memCacheHeight` based on tile size + device pixel ratio.
- Optional wishlist heart overlay / trailing overlay.
- Text: brand (uppercase), title, price chip.
- Compact behavior when narrow (`maxWidth < 180`) reduces title lines.
- Default card height is `184.h`.
- Supports `fillHeight` for grids that want tiles to expand.
- Includes a very-tight constraint fallback (title + price only) to avoid overflow.

### Grid rules (columns by screen size)

From `home_screen.dart`:
- Default grids use `SliverGridDelegateWithFixedCrossAxisCount` with `childAspectRatio: 0.6`.
- `crossAxisCount` varies by width:
  - `< 400`: 3
  - `< 520`: 4
  - `>= 520`: 5
- Some sections use:
  - `< 520`: 3
  - `< 720`: 4
  - `>= 720`: 5

### Splash behavior

- Uses **native** Android/iOS launch screens (no Flutter overlay splash).
- Android: launch theme resources.
- iOS: `LaunchScreen` storyboard.

---

## Tech stack

### Core

- Flutter / Dart (SDK constraint: `sdk: ^3.8.1`)
- Material 3
- State management: `flutter_riverpod` (`^2.6.1`)
- Routing: `go_router` (`^14.8.1`)

### Firebase

- `firebase_core` (`^3.15.0`)
- `cloud_firestore` (`^5.6.0`)
- `firebase_auth` (`^5.6.0`)
- `google_sign_in` (`^6.2.2`)

### Local storage / caching

- `shared_preferences` (`^2.3.5`) — wishlist, recently viewed, local cart, checkout address persistence
- `cached_network_image` (`^3.3.1`)
- `flutter_secure_storage` (`^9.2.2`) via `SecureStore` abstraction
- `hive` / `hive_flutter` (present in deps; used for some local storage)

### Utilities

- `flutter_screenutil` (`^5.9.3`)
- `uuid` (`^4.5.1`)
- `http` (`^1.2.2`)
- `phone_number` (`^2.1.0`)
- `country_picker` (`^2.0.26`)

### On-device ML

- `tflite_flutter` (model asset: `assets/models/ai_nav_model_quant.tflite`)

---

## Project structure

High-level layout:

```text
lib/
  main.dart
  app.dart
  core/          # routing, theme, shared widgets, config, error mapping, telemetry abstractions
  domain/        # entities + repository interfaces
  data/          # datasources + repository implementations (Firestore, SharedPrefs, fakes), syncing strategies
  features/      # feature-first UI (home, product, cart, checkout, wishlist, orders, auth, ai, profile, ...)
test/            # unit + widget + golden tests
```

---

## Getting started

### Prerequisites

- Flutter SDK (3.x)
- Dart SDK (3.x)

Install dependencies:

```bash
flutter pub get
```

Run quality checks:

```bash
dart format .
flutter analyze
flutter test
```

Run the app:

```bash
flutter run
```

---

## Configuration & feature flags

### Demo / repositories

- `USE_FAKE_REPOS=true` → run using in-memory/fake repositories (no Firebase required)

### Firebase emulators

- `USE_FIRESTORE_EMULATOR=true`
- `FIRESTORE_HOST` (e.g. `localhost` for iOS Simulator, `10.0.2.2` for Android Emulator)
- `FIRESTORE_PORT` (default: `8080` in examples)
- `AUTH_PORT` (default: `9099` in examples)

### Optional integrations

- **Places Autocomplete (Checkout)**
  - Enable the feature flag in `AppEnv` (`enablePlacesAutocomplete`)
  - Provide `GOOGLE_PLACES_API_KEY`
  - Manual entry always remains available as a fallback

### UI experiments

- **Nova UI**
  - Enable `AppEnv.enableNovaUi` and per-screen gates (e.g. checkout)
  - Defaults to Material widgets when disabled

> Notes:
> - Feature flags are intentionally conservative and **off by default** for a stable MVP.
> - In this repo, the “Nova AI chat” is also intentionally a placeholder (fake repo).

---

## Firebase setup

This app uses **client-side Firebase configuration** (no server-side secrets are included in this repository).

### Option A — Use your own Firebase project (recommended)

1. Create a Firebase project.
2. Enable Authentication providers (Anonymous / Email-Password / Google).
3. Create Firestore collections:
   - `products`
   - `orders`
   - (optional) `carts` (for signed-in cart sync)
4. From the repo root, run:

```bash
flutterfire configure
```

This generates:

- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`
- `lib/firebase_options.dart`

> Tip: If your product query orders by `createdAt`, ensure product docs contain `createdAt` and any flags you filter on (e.g. `featured: true`).

---

## Emulators

Start emulators:

```bash
firebase emulators:start --only firestore,auth
```

Run app using emulators (examples):

### iOS Simulator

```bash
flutter run   --dart-define=USE_FIRESTORE_EMULATOR=true   --dart-define=FIRESTORE_HOST=localhost   --dart-define=FIRESTORE_PORT=8080   --dart-define=AUTH_PORT=9099
```

### Android Emulator

```bash
flutter run   --dart-define=USE_FIRESTORE_EMULATOR=true   --dart-define=FIRESTORE_HOST=10.0.2.2   --dart-define=FIRESTORE_PORT=8080   --dart-define=AUTH_PORT=9099
```

> Notes:
> - On Android Emulator, `10.0.2.2` routes to your host machine.
> - On a physical device, use your machine’s LAN IP (e.g., `192.168.x.x`).

---

## Demo mode

Run with in-memory repositories (no Firebase required):

```bash
flutter run --dart-define=USE_FAKE_REPOS=true
```

---

## Testing

This repository contains a large `test/` suite including:
- unit tests for controllers/viewmodels/mappers
- widget tests across features (AI chat, checkout viewmodel, orders controller, profile screens, product details, cart migration, …)
- golden tests (tagged)

### Windows note (goldens)

Golden tests are skipped on Windows due to Flutter tool temp cleanup flakiness. They are intended to run in CI and on non‑Windows environments.

### Commands

```bash
# Non-golden tests (all platforms)
flutter test --exclude-tags=golden

# Golden tests (CI / non-Windows)
flutter test --tags=golden
```

---

## Known limitations

- **Shipping fee** is currently a constant `0.0` (no rate quotes).
- **Payments** are entirely out of scope.
- **Checkout is not trusted server-side**:
  - order placement + stock decrement currently happen in a client Firestore transaction.
  - no Cloud Functions backend is committed (`functions/` exists but is empty).
- **AI chat** is a placeholder (fake repo).
- **No operational tooling**:
  - no admin UI, no inventory editor, no order management UI.

---

## Roadmap ideas

Short “next phase” ideas (non-committal):

- Move checkout/order placement to a **trusted server layer** (Cloud Functions / server) and tighten Firestore rules accordingly.
- Add stronger server-side validation for pricing/totals and cart integrity.
- Add operational tooling (admin workflows):
  - inventory/variants editor
  - orders management (status changes, cancellations/refunds if payments ever added)
- Performance:
  - further optimize image prefetching + caching policy
  - consider background sync policies in poor connectivity scenarios

---

## License

This repository is provided for **review and evaluation purposes only**.
It is **not open-source** and may not be reused, redistributed, or deployed without explicit written permission.

See [LICENSE](LICENSE).
