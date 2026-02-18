# GoodBean — AI Development Guide

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

## App Navigation Structure

The app uses a bottom tab bar with icon-only navigation (no text labels). Four main sections:

- **Cafe** (`CafePage`) — The user's home page. This is where they log new espresso pulls and view/edit their equipment setup (grinder, machine, accessories). Default landing tab.
- **Feed** (`FeedPage`) — The social page. Users can see other users' activities, shared shot profiles, and public bean reviews from the community.
- **Visualize** (`VisualizePage`) — The data dashboard. Displays the user's espresso data in an engaging way — extraction trends, "Golden Ratio" charts, and personalized statistics.
- **Profile** (`ProfilePage`) — Account management. Users can manage their settings, update preferences, view their profile info, and log out.

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

## Repo Structure

```
/
├── supabase/              # Supabase CLI root
│   ├── migrations/        # SQL migration files (DB source of truth)
│   └── functions/         # TypeScript Edge Functions
├── ios/                   # SwiftUI Xcode Project
│   ├── Models/            # Codable structs mirroring DB tables
│   ├── Views/             # UI Components
│   └── Services/          # Supabase Client & API wrappers
├── scripts/               # Agent workflow scripts
├── .claude/               # Claude Code project config
└── CLAUDE.md              # This file
```

---

## Current Schema

Three tables defined in `supabase/migrations/`. Check migration files for exact column definitions.

- **`profiles`** — `id (uuid, FK auth.users)`, `username (text)`, `equipment_setup (jsonb)`
- **`beans`** — `id`, `created_by`, `roaster`, `name`, `roast_level`, `roast_date`, `is_public`, `notes`
- **`shot_pulls`** — `id`, `user_id`, `bean_id`, `dose_grams`, `yield_grams`, `time_seconds`, `temp_c`, `pressure_profile (jsonb)`, `rating`, `is_public`

All tables have RLS enabled with appropriate SELECT/INSERT/UPDATE policies.

---

## Agent Constraints

1. **Atomic schema updates:** When updating the DB schema, you **must** create a migration file in `supabase/migrations/` AND update the corresponding Swift `Codable` structs in `ios/Models/` in the same commit.
2. **Type safety:** Use Postgres **ENUMs** for categorical values (roast levels, grind settings). Ensure Swift models use matching enums.
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
4. **Build & test** — use XcodeBuildMCP or xcodebuild to verify
5. **Commit** — atomic commits grouping related changes
6. **Push** — push your feature branch
7. **Create PR** — use `gh pr create` (see PR instructions below)

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
