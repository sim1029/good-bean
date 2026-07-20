# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**GoodBean** is a minimalist iOS espresso tracking app for coffee enthusiasts ("nerds") requiring granular data tracking and social sharing.

**Status:** Initial Scaffolding Phase

**Architecture:** SwiftUI + Supabase monorepo ("backend-less")

Users can:
1. **Dial In** — Record granular espresso pull data (dose, yield, time, temp, pressure)
2. **Inventory** — Track coffee beans by roaster, roast date, and variety
3. **Visualize** — View extraction trends and "Golden Ratio" charts
4. **Social** — Share public shot profiles and bean reviews with a community feed

---

## Build & Development Commands

### Build (via XcodeBuildMCP — preferred)
Use the `build` and `test` MCP tools from XcodeBuildMCP. Fallbacks:

```bash
# Build for simulator
xcodebuild -project ios/GoodBean.xcodeproj -scheme GoodBean -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild -project ios/GoodBean.xcodeproj -scheme GoodBean -destination 'platform=iOS Simulator,name=iPhone 16' test

# Boot simulator and take screenshot
xcrun simctl boot "iPhone 16"
xcrun simctl screenshot booted screenshot.png
```

### Lint & Format
```bash
swiftlint lint ios/GoodBean/
swiftformat ios/GoodBean/
```

### Agent Workflow Scripts
```bash
# Create a git worktree for an agent task branch
./scripts/agent-worktree.sh <task-slug> [prompt]
# Creates branch agent/<task-slug>, launches Claude Code in worktree

# Clean up merged worktrees
./scripts/agent-cleanup.sh <task-slug>
./scripts/agent-cleanup.sh --all-merged
```

---

## App Navigation Structure

The app uses a bottom tab bar with icon-only navigation (no text labels). Four main sections:

- **Cafe** (`CafePage`) — Home tab. Log espresso pulls & manage equipment setup. Default landing tab.
- **Feed** (`FeedPage`) — Social tab. Community shot profiles and bean reviews.
- **Visualize** (`VisualizePage`) — Data dashboard. Extraction trends, "Golden Ratio" charts.
- **Profile** (`ProfilePage`) — Account management, settings, and log out.

Tab icons (SF Symbols): `cup.and.saucer.fill`, `person.2.fill`, `chart.bar.fill`, `person.crop.circle.fill`

---

## Tech Stack

- **Frontend:** SwiftUI (iOS 17+ target)
  - State management: `@Observable` macro (Swift 6)
  - Networking: `supabase-swift` SDK with native `async/await`
  - Charts: Swift Charts for extraction curves
- **Backend & Database:** Supabase (Postgres)
  - Row Level Security (RLS) for all permissions
  - TypeScript Edge Functions (Deno) for heavy lifting / external APIs
  - Migrations: version-controlled SQL in `supabase/migrations/`
- **Tooling:**
  - MCP servers: Supabase (schema introspection), XcodeBuildMCP (build/test)
  - SwiftLint / SwiftFormat for idiomatic Swift code

---

## Code Architecture

### Service Layer

**`SupabaseClient.swift`** — Singleton `SupabaseService` with generic async helpers:
- `fetchAll<T: Decodable>(from:)` — fetch all rows from a table
- `fetchById<T: Decodable>(from:id:)` — fetch single row by UUID
- `insert<T: Encodable>(into:value:)` — insert a row
- Convenience methods: `getBeans()`, `getBean(id:)`, `getProfiles()`, `getProfile(id:)`

**`AuthenticationManager.swift`** — `@Observable` class managing the auth lifecycle:
- OAuth (Google, Facebook), phone OTP, and `DEBUG`-only test user sign-in
- Holds the current `Session`; `GoodBeanApp` uses it as the auth gate
- Test user: `testuser@goodbean.dev` / `testpassword123` (UUID: `a1b2c3d4-e5f6-7890-abcd-ef1234567890`)

**`DevSettings.swift`** — `#if DEBUG` enum with test credentials; excluded from release builds.

### Models

- **`Profile.swift`** — Mirrors `profiles` table. Includes nested `EquipmentSetup` struct (grinder, machine, tamper).
- **`Bean.swift`** — Mirrors `beans` table.
- **`ShotPull` model does not exist yet** — the `shot_pulls` DB table is defined but the Swift model still needs to be created.

### Views

- **`ContentView.swift`** — Root `TabView` with 4 tabs, guarded by auth state.
- **`LoginView.swift`** — Full auth UI (OAuth buttons, phone OTP, DEBUG test-user button).
- **`BeansListView.swift`** — Functional; fetches and displays beans with loading/error states.
- **`CafePage`, `FeedPage`, `VisualizePage`, `ProfilePage`** — All currently placeholder stubs.

---

## Current Schema

Three tables in `supabase/migrations/`. Check migration files for exact column definitions.

- **`profiles`** — `id (uuid, FK auth.users)`, `username (text)`, `equipment_setup (jsonb)`
- **`beans`** — `id`, `created_by`, `roaster`, `name`, `roast_level`, `roast_date`, `is_public`, `notes`
  - `roast_level` uses a CHECK constraint (`'light' | 'medium' | 'dark'`) — not a Postgres ENUM yet
- **`shot_pulls`** — `id`, `user_id`, `bean_id`, `dose_grams`, `yield_grams`, `time_seconds`, `temp_c`, `pressure_profile (jsonb)`, `rating`, `is_public`

Seed data: 5 public sample beans, 1 test user with profile + 2 private beans + 3 shot pulls.

---

## Agent Constraints

1. **Atomic schema updates:** When updating the DB schema, you **must** create a migration file in `supabase/migrations/` AND update the corresponding Swift `Codable` structs in `ios/Models/` in the same commit.
2. **Type safety:** Use Postgres **ENUMs** for new categorical values (grind settings, etc.). Ensure Swift models use matching enums. (Note: existing `roast_level` uses a CHECK constraint — migrate to ENUM before expanding it.)
3. **Security first:** Never bypass RLS. All new tables must have `ENABLE ROW LEVEL SECURITY` and appropriate policies.
4. **Concurrency:** Swift 6 `async/await` and `Task` groups only. No `Combine` or completion handlers.
5. **UI philosophy:** Minimalist nerd aesthetic — high data density, clean whitespace-heavy layout. Use **Swift Charts** for all data visualization.

---

## MCP Usage

### Supabase MCP
- Use `list_tables`, `execute_sql` for schema introspection and read queries
- **Do not** run DDL through MCP — always write migration files manually in `supabase/migrations/`

### XcodeBuildMCP
- Use `build`, `test`, `screenshot` tools to validate iOS changes
- Fallback: run `xcodebuild` or `xcrun simctl` via bash if MCP is unavailable

---

## Task Workflow

1. **Check migrations** — read `supabase/migrations/` to understand current schema state
2. **Plan** — propose a plan covering both SQL migration and Swift implementation
3. **Implement** — write code (migration + Swift models/views/services together)
4. **Build & verify** — confirm it compiles (xcodebuild / XcodeBuildMCP). For anything UI/UX, hand off to the owner per **UI/UX Verification** below rather than judging the result yourself.
5. **Commit** — atomic commits grouping related changes
6. **Push** — push your feature branch
7. **Create PR** — use `gh pr create`

---

## UI/UX Verification

**The repo owner owns UI/UX judgment — the agent does not.** The owner has the taste and verifies visuals/interaction on their own iPhone; the agent is explicitly not trusted to assess how something looks or feels.

So when a change affects UI or UX:
- **Do not** claim a UI/UX outcome is good, correct, or done based on your own inspection or screenshots.
- **Do** give the owner clear, in-depth **testing instructions**: exactly which screen(s) to open, what actions to take (taps, swipes, long-presses, menu selections), what the expected result is, and the specific things to look for (spacing, color/theme in both light and dark mode, alignment, states like empty/loading/error, edge cases). Be concrete enough that they can follow it without guessing.
- You may still verify the non-visual parts yourself (compiles, data decodes, network/DB writes succeed, logic is correct) and report those plainly.

---

## PR Instructions

- Use `gh pr create` to open pull requests
- Prefix title with `[DB]` if the PR includes migration files
- Include a summary and testing checklist in the PR body
- Target `main` as the base branch

---

## Prohibitions

- **No pushing to main** — always use feature branches
- **No force-push** — ever
- **No .env commits** — secrets must never be committed
- **No bypassing RLS** — every table needs proper security policies

---

## Design System

**Aesthetic:** Third-wave specialty coffee shop — warm, sophisticated, minimal. Think Intelligentsia or Blue Bottle. High data density for the espresso nerd. One amber accent, warm neutrals, monospaced fonts for metrics.

All tokens live in `ios/GoodBean/AppTheme.swift`. Never hardcode colors, fonts, spacing, or radius values — always use the token references below.

### Color Palette

| Token | Light `#hex` | Dark `#hex` | Usage |
|---|---|---|---|
| `Color.gbBackground` | `#FAFAF8` | `#111009` | Window/screen background |
| `Color.gbSurface` | `#F2EDE8` | `#1E1B17` | Cards, inputs, list rows |
| `Color.gbTextPrimary` | `#1A1614` | `#F5F0EB` | Headings, readable text |
| `Color.gbTextSecondary` | `#6B5F57` | `#9C8E84` | Metadata, secondary labels |
| `Color.gbTextTertiary` | `#A8998F` | `#6B5F57` | Placeholders, muted captions |
| `Color.gbAccent` | `#B8712A` | `#D4924D` | CTAs, active states, highlights |
| `Color.gbSeparator` | `#E8E0D8` | `#2A251F` | Dividers, subtle borders |

### Typography

All fonts via `Theme.Font.*`:

| Token | Weight | Size | Design |
|---|---|---|---|
| `Theme.Font.display` | Bold | 28pt | Wordmark, hero headings |
| `Theme.Font.title` | Semibold | 20pt | Nav titles, card section headers |
| `Theme.Font.headline` | Medium | 16pt | Card headings, bean/shot names |
| `Theme.Font.body` | Regular | 14pt | Body copy, button labels |
| `Theme.Font.caption` | Regular | 12pt | Metadata, timestamps, labels |
| `Theme.Font.data` | Medium | 14pt | **Monospaced** — shot metrics |
| `Theme.Font.dataLarge` | Bold | 22pt | **Monospaced** — large numeric readouts |

### Spacing (4pt grid)

All spacing via `Theme.Spacing.*`:

| Token | Value | Usage |
|---|---|---|
| `Theme.Spacing.xs` | 4pt | Tight internal gaps (icon-text, pip spacing) |
| `Theme.Spacing.sm` | 8pt | Between related items (button stacks) |
| `Theme.Spacing.md` | 16pt | Card padding, standard insets |
| `Theme.Spacing.lg` | 24pt | Section gaps, generous card padding |
| `Theme.Spacing.xl` | 32pt | Large vertical rhythm |
| `Theme.Spacing.xxl` | 48pt | Bottom safe area clearance |

### Corner Radius

All radius via `Theme.Radius.*`:

| Token | Value | Usage |
|---|---|---|
| `Theme.Radius.sm` | 6pt | Filter pills, small chips |
| `Theme.Radius.md` | 10pt | Cards, primary buttons, inputs |
| `Theme.Radius.lg` | 16pt | Bottom sheets, large surfaces |

### Component Patterns

**Cards:** Apply `.gbCardStyle()` modifier — sets `gbSurface` background, `md` corner radius, 1pt `gbSeparator` border. No shadows.

**Section labels:** `ALL CAPS`, `Theme.Font.caption`, `Color.gbTextTertiary`, 1pt letter-spacing (`kerning(1)`).

**Primary buttons:** `GBPrimaryButtonStyle` — full-width, amber fill, white text.

**Secondary buttons:** `GBSecondaryButtonStyle` — full-width, transparent fill, amber border and text.

**Destructive actions:** Inline styling with `Color.red` foreground and `Color.red.opacity(0.5)` border — do not override `GBSecondaryButtonStyle` foreground after application.

**Data display:** Always use `Theme.Font.data` (14pt monospaced) for shot metrics inline, `Theme.Font.dataLarge` (22pt monospaced bold) for hero stat readouts.

**Rating pips:** 10 × 3pt-wide `RoundedRectangle` bars, amber-filled up to rating, `gbSeparator` for remainder.

**Avatar circles:** `gbAccent.opacity(0.15)` fill, initials in `gbAccent`.

### Aesthetic Rules

1. **No shadows** — depth comes from surface/background contrast and separator borders only.
2. **One accent per screen** — amber (`gbAccent`) is reserved for CTAs, active states, and key metrics. Do not use it decoratively.
3. **Monospaced for all metrics** — any numeric shot data (dose, yield, time, temp, ratio) must use `Theme.Font.data` or `Theme.Font.dataLarge`.
4. **Warm neutrals for everything else** — text, icons, and borders use the `gbText*` and `gbSeparator` palette.
5. **All screens set background** — every root `NavigationStack` or `ZStack` must set `.background(Color.gbBackground)`.
6. **Tab bar tint** — `TabView` always carries `.tint(.gbAccent)` to amber-highlight the active tab icon.
