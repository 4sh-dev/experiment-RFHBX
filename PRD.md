# Mordor's Edge - Demo & Disaster Recovery Training Platform

> "One does not simply walk into production without testing disaster recovery."

## Overview

Mordor's Edge is a Rails + React demo application designed for **deployment testing** and **disaster recovery training**. It provides a realistic, full-stack environment where teams can practice firefighting production incidents by intentionally breaking things in a controlled setting.

The application uses Lord of the Rings themed data throughout (characters, locations, quests, artifacts) to make the demo environment engaging and easy to reason about.

## Goals

1. **Deployment Testing** - Validate CI/CD pipelines, infrastructure provisioning, and deployment workflows
2. **Disaster Recovery Training** - Provide a realistic app that can be intentionally broken to teach incident response
3. **Integration Testing** - Exercise real-world integrations (Redis, SQS, WebSockets, OIDC) in a safe environment
4. **Team Training** - Give engineers hands-on experience with production-like failures

## Architecture

```
                                    +------------------+
                                    |   React (Vite)   |
                                    |   Frontend SPA   |
                                    +--------+---------+
                                             |
                                             v
+------------------+          +------------------+          +------------------+
|   Amazon SQS     |<-------->|   Rails API      |<-------->|   PostgreSQL     |
|   (via Shoryuken)|          |   (Backend)      |          |   (Database)     |
+------------------+          +--------+---------+          +------------------+
                                       |
                              +--------+---------+
                              |                  |
                       +------v------+    +------v------+
                       |   Redis     |    |   OIDC      |
                       |   Sidekiq   |    |   Provider  |
                       +-------------+    +-------------+
```

### Frontend serves from Rails

The React SPA is built by Vite and its output is served by Rails at the root URL (`/`). The architecture allows decoupling the frontend to its own server in the future.

---

## Phase 1: Project Foundation

**Goal:** Establish the project skeleton, CI pipeline, local dev environment, and basic health checks.

### 1.1 Rails API Setup
- Initialize Rails 8.1 API-mode application with PostgreSQL
- Ruby 4.0
- Configure RSpec as the test framework
- Add health check endpoint (`GET /api/health`) returning `{ status: "ok", version: "...", environment: "..." }`
- Configure CORS for frontend dev server

### 1.2 React Frontend Setup
- Initialize React 19.2 + TypeScript project with Vite 8 (react-swc-ts template)
- Configure Biome.js 2.x for linting and formatting
- Install and configure: Mantine 8.3, Zustand 5, TanStack Router 1.x, Axios, Zod, es-toolkit
- Node.js 24 LTS
- npm for package management
- Add Vitest for testing
- Create root layout with Mantine AppShell with dark/light mode toggle (default: dark)
- **Retro pixel gaming aesthetic:** pixel font (e.g., Press Start 2P), 8-bit styled borders and UI elements, retro color palette. Mantine components customized via theme overrides to match the pixel RPG look.
- Pixel art character/artifact portraits (use or generate a consistent sprite set for all seed characters and artifacts)
- Wire up Axios client to point at Rails API base URL
- Landing page that calls the health endpoint and displays status

### 1.3 Local Docker Environment
- `docker-compose.yml` with services: rails, postgres, redis, frontend
- Rails runs with file watching / auto-reload
- Frontend runs Vite dev server with HMR
- Postgres and Redis as backing services
- Volume mounts for live code editing
- Environment variable configuration via `.env` file

### 1.4 CI Pipeline (GitHub Actions)
- Workflow triggers on push and PR to `main`
- **Backend job:** Ruby setup, bundle install, RSpec with PostgreSQL service container
- **Frontend job:** Node setup, npm ci, Biome check, Vitest
- Both jobs must pass before merge
- Pre-push git hook to run tests locally before pushing

---

## Phase 2: Core Data & REST API

**Goal:** Build the LOTR-themed data model and REST API with OpenAPI documentation.

### 2.1 Data Model (LOTR Theme)

**Characters** (The Fellowship and beyond)
- `name` (string, required) - e.g., "Aragorn", "Gandalf", "Frodo"
- `race` (string, required) - e.g., "Human", "Maiar", "Hobbit", "Elf", "Dwarf", "Ent"
- `realm` (string) - e.g., "Gondor", "The Shire", "Rivendell"
- `title` (string) - e.g., "King of Gondor", "The Grey Pilgrim"
- `ring_bearer` (boolean, default: false)
- `level` (integer, default: 1)
- `xp` (integer, default: 0) - experience points, level up at thresholds
- `strength` (integer, default: 5) - base combat stat (1-20)
- `wisdom` (integer, default: 5) - base magic/strategy stat (1-20)
- `endurance` (integer, default: 5) - base resilience stat (1-20)
- `status` (enum: idle, on_quest, fallen; default: idle)

**Quests**
- `title` (string, required) - e.g., "Destroy the One Ring"
- `description` (text)
- `status` (enum: pending, active, completed, failed)
- `danger_level` (integer, 1-10)
- `region` (string) - e.g., "Mordor", "Moria", "Helm's Deep"
- `progress` (decimal, default: 0.0) - completion percentage (0.0 to 100.0)
- `success_chance` (decimal) - calculated from party strength vs danger_level
- `quest_type` (enum: campaign, random; default: campaign)
- `campaign_order` (integer, nullable) - sequence number for campaign mode
- `attempts` (integer, default: 0) - how many times this quest has been attempted

**Quest Memberships** (join table)
- `character_id` (references)
- `quest_id` (references)
- `role` (string) - e.g., "Ring Bearer", "Guide", "Protector"
- Constraint: a character can only belong to one active quest at a time

**Artifacts**
- `name` (string, required) - e.g., "The One Ring", "Anduril", "Sting"
- `artifact_type` (string) - e.g., "Ring", "Sword", "Staff"
- `power` (text) - description of the artifact's power
- `corrupted` (boolean, default: false)
- `character_id` (references, nullable) - current holder
- `stat_bonus` (jsonb, default: {}) - e.g., `{ "strength": 3, "wisdom": 1 }`

**Quest Events** (log of what happens during quests)
- `quest_id` (references)
- `event_type` (enum: started, progress, completed, failed, restarted)
- `message` (text) - narrative description of what happened
- `data` (jsonb) - structured event data (progress %, XP awarded, etc.)
- `created_at` (timestamp)

**Simulation Config** (singleton settings)
- `mode` (enum: campaign, random; default: campaign)
- `running` (boolean, default: false)
- `tick_interval_seconds` (integer, default: 60)
- `progress_min` (decimal, default: 0.01) - min progress per tick (%)
- `progress_max` (decimal, default: 0.1) - max progress per tick (%)
- `campaign_position` (integer, default: 0) - current quest in campaign sequence

### 2.2 REST API Endpoints

All endpoints under `/api/v1/`:

| Method | Path | Description |
|--------|------|-------------|
| GET | `/characters` | List all characters (paginated) |
| GET | `/characters/:id` | Get character details with quests and artifacts |
| POST | `/characters` | Create a character |
| PATCH | `/characters/:id` | Update a character |
| DELETE | `/characters/:id` | Delete a character |
| GET | `/quests` | List all quests (paginated, filterable by status) |
| GET | `/quests/:id` | Get quest details with members |
| POST | `/quests` | Create a quest |
| PATCH | `/quests/:id` | Update a quest |
| DELETE | `/quests/:id` | Delete a quest |
| POST | `/quests/:id/members` | Add character to quest |
| DELETE | `/quests/:id/members/:character_id` | Remove character from quest |
| GET | `/artifacts` | List all artifacts |
| GET | `/artifacts/:id` | Get artifact details |
| POST | `/artifacts` | Create an artifact |
| PATCH | `/artifacts/:id` | Update an artifact |
| GET | `/simulation/status` | Get simulation state |
| POST | `/simulation/start` | Start the simulation |
| POST | `/simulation/stop` | Stop the simulation |
| POST | `/simulation/mode` | Switch campaign/random mode |
| POST | `/simulation/reset` | Reset all progress (requires `confirm: true`) |
| GET | `/quests/:id/events` | Get event log for a quest |
| GET | `/events` | Get all events (paginated, filterable) |
| GET | `/leaderboard` | Characters ranked by level/XP |
| POST | `/palantir/send` | Send a Palantir message (SQS test) |

### 2.3 OpenAPI & Scalar UI
- Generate OpenAPI 3.1 spec from RSpec request specs (using rswag)
- Expose spec at `/api/docs.json`
- Mount Scalar UI at `/api/docs` for interactive API exploration
- Spec includes request/response schemas, examples with LOTR data

### 2.4 Seed Data
- Seed script populating the Fellowship of the Ring, key quests, and notable artifacts
- At least 25 characters, 10 quests, and 16 artifacts

---

## Phase 3: GraphQL API

**Goal:** Add a GraphQL endpoint alongside REST.

### 3.1 GraphQL Setup
- Install `graphql-ruby`
- Mount GraphQL endpoint at `/api/graphql`
- GraphiQL UI available in development

### 3.2 GraphQL Schema
- Query types for Characters, Quests, Artifacts
- Nested queries (e.g., character -> quests -> members)
- Mutations for create/update operations
- Input validation matching REST API rules

---

## Phase 4: Background Jobs, Messaging & Quest Simulation

**Goal:** Integrate Sidekiq (Redis) and Shoryuken (SQS) for background processing, and build the live quest simulation engine.

### 4.1 Redis / Sidekiq Integration
- Configure Sidekiq with Redis
- Add Sidekiq Web UI (mounted at `/admin/sidekiq`, protected)
- Configure sidekiq-cron for recurring jobs

### 4.2 Quest Simulation Engine

The core game loop, driven by a recurring Sidekiq worker that ticks once per minute.

**Quest Tick Worker** (runs every minute when simulation is running):
1. Find all quests with `status: active`
2. For each active quest, increment `progress` by a random amount between `progress_min` and `progress_max` (default 0.01% to 0.1%)
3. Broadcast progress update via ActionCable (Phase 5)
4. Create a `QuestEvent` with a narrative message (e.g., "The Fellowship crosses the Misty Mountains...")
5. When `progress` reaches 100%:
   - Roll success/failure based on `success_chance`
   - **On success:** mark quest completed, award full XP to all party members, level up characters that cross XP thresholds, set characters back to `idle`
   - **On failure:** mark quest failed, award partial XP (25%), set characters back to `idle`, reset quest (`progress: 0`, `attempts += 1`, `status: pending`), then immediately re-activate with same party
6. After resolving completed/failed quests, if there are idle characters:
   - **Campaign mode:** activate the next quest in `campaign_order` sequence, assign its book-accurate party
   - **Random mode:** generate a random quest with random difficulty, assign a random subset of idle characters
7. Recalculate `success_chance` for newly activated quests

**Success Chance Formula:**
```
party_power = sum of (character.strength + character.wisdom + character.endurance + artifact_bonuses) for each member
                * level_multiplier (1 + 0.1 per level)
difficulty = danger_level * 100
success_chance = clamp(party_power / difficulty * 50, 5, 95)
```
Always at least 5% chance of failure and 5% chance of success.

**XP and Leveling:**
- XP on success: `danger_level * 100`
- XP on failure: `danger_level * 25`
- Level thresholds: Level N requires `N * 500` total XP (Level 2 = 500 XP, Level 3 = 1000 XP, etc.)
- On level up: +1 to a random stat (strength, wisdom, or endurance)

**Simulation Modes:**
- **Campaign mode** (default): Replays the LOTR story. Quests activate in `campaign_order` with book-accurate character assignments. When the campaign completes, automatically switches to random mode.
- **Random mode:** Endless sandbox. Generates random quests from a pool of quest templates with random difficulty and random parties from idle characters.
- Toggle between modes via `POST /api/v1/simulation/mode` (switching to campaign resets and starts from the beginning)

**Simulation Controls:**
- `POST /api/v1/simulation/start` - start the simulation
- `POST /api/v1/simulation/stop` - pause the simulation
- `POST /api/v1/simulation/mode` - switch between campaign/random
- `GET /api/v1/simulation/status` - current state (running, mode, campaign position, tick count)
- `POST /api/v1/simulation/reset` - stop simulation, reset all characters to base stats/level 1/idle, reset all quests to pending/0 progress/0 attempts, clear quest events, reset campaign position to 0. Requires confirmation param (`{ confirm: true }`).

### 4.3 SQS / Shoryuken Integration
- Configure Shoryuken for SQS-backed job processing
- **"Palantir Message" endpoint:** `POST /api/v1/palantir/send` accepts a message, enqueues it to SQS. Shoryuken processes the message, creates a `QuestEvent` record, and the result appears in the live event feed.
- For local development, use ElasticMQ (SQS-compatible) in Docker
- Provides ability to test SQS integration without AWS in local/CI

### 4.4 Recurring Job - The Eye of Sauron
- Sidekiq cron job running every minute (separate from quest tick)
- Broadcasts a "Sauron's Gaze" event with a random update (which region Sauron is watching, threat level changes based on active quest locations)
- Delivered to connected frontends via WebSocket/SSE (Phase 5)

---

## Phase 5: Real-time Communication

**Goal:** WebSocket/SSE support for live updates.

### 5.1 ActionCable / SSE Setup
- Configure ActionCable with Redis adapter
- SSE endpoint as fallback: `GET /api/v1/events/stream`
- Frontend connects on load and displays live events

### 5.2 Real-time Features
- **Quest progress updates** - each tick broadcasts progress for all active quests
- **Quest completion/failure** - broadcast when quests resolve with narrative outcome
- **Character level ups** - broadcast when a character gains a level
- **Eye of Sauron** - broadcasts from the recurring job (Phase 4.4)
- **Palantir messages** - Shoryuken processing notifications
- Frontend displays a live event feed with timestamps and event type filtering

---

## Phase 6: Authentication

**Goal:** OIDC-based authentication.

### 6.1 OIDC Integration
- Configure OmniAuth with OIDC strategy
- Support configurable OIDC provider (for different deployment environments)
- Session management with secure cookies
- Protected API endpoints require valid session or bearer token
- `/api/v1/auth/me` endpoint returning current user info

### 6.2 Frontend Auth Flow
- Login button redirecting to OIDC provider
- Callback handling and session storage
- Protected routes in TanStack Router
- User info display in header
- Logout flow

---

## Phase 7: Frontend Features

**Goal:** Build out the React UI for all backend features.

### 7.1 Pages & Components
- **Live Quest Dashboard** (main page) - Real-time view of all active quests with progress bars, party members, success chance, and a scrolling event log. Simulation controls (start/stop/mode toggle) at the top.
- **Characters** - List view with level, stats, XP progress bar, current quest status (idle/on quest). Detail view shows quest history, level-up timeline, and equipped artifacts.
- **Quests** - List view filterable by status (active/completed/failed/pending). Detail view shows party, progress, attempt count, and event log for that quest.
- **Artifacts** - List/detail views, current holder, stat bonuses
- **Palantir** - Send messages (SQS test) and view processed events
- **Leaderboard** - Characters ranked by level/XP, quests completed count
- **Quest Log** - Chronological history of all quest events across the simulation

### 7.2 State Management
- Zustand stores for: characters, quests, artifacts, events, simulation, auth
- Real-time store updates via WebSocket subscriptions (quest progress, events)
- Zod schemas for API response validation
- Axios interceptors for auth token injection and error handling

### 7.3 Frontend Testing
- Vitest for unit tests
- Component tests for critical UI paths
- API client tests with mocked responses

---

## Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| API mode | Rails API-only + separate Vite build | Allows future frontend decoupling |
| Test framework (BE) | RSpec | Industry standard for Rails |
| Test framework (FE) | Vitest | Native Vite integration, fast |
| SQS local | ElasticMQ | Drop-in SQS replacement for dev/test |
| Real-time | ActionCable + SSE fallback | Built into Rails, SSE for simpler clients |
| OpenAPI | rswag | Test-driven spec generation with Swagger UI |
| Auth | OmniAuth + OIDC | Flexible provider support |

---

## LOTR Seed Data Reference

### Characters
| Name | Race | Realm | Title |
|------|------|-------|-------|
| Frodo Baggins | Hobbit | The Shire | Ring Bearer |
| Samwise Gamgee | Hobbit | The Shire | Mayor of the Shire |
| Aragorn | Human | Gondor | King Elessar |
| Gandalf | Maiar | Valinor | The White |
| Legolas | Elf | Woodland Realm | Prince of Mirkwood |
| Gimli | Dwarf | Erebor | Lord of the Glittering Caves |
| Boromir | Human | Gondor | Captain of the White Tower |
| Pippin | Hobbit | The Shire | Guard of the Citadel |
| Merry | Hobbit | The Shire | Knight of Rohan |
| Eowyn | Human | Rohan | Shieldmaiden of Rohan |
| Faramir | Human | Gondor | Prince of Ithilien |
| Galadriel | Elf | Lothlorien | Lady of Light |
| Elrond | Elf | Rivendell | Lord of Rivendell |
| Saruman | Maiar | Isengard | The White (fallen) |
| Sauron | Maiar | Mordor | The Dark Lord |
| Tom Bombadil | Unknown | Old Forest | Master of Wood, Water, and Hill |
| Goldberry | Unknown | Old Forest | River-daughter |
| Glorfindel | Elf | Rivendell | Lord of the House of the Golden Flower |
| Beregond | Human | Gondor | Guard of the Citadel |
| Farmer Maggot | Hobbit | The Shire | Farmer of Bamfurlong |
| Ghân-buri-Ghân | Wild Man | Druadan Forest | Chieftain of the Woses |
| Radagast | Maiar | Rhosgobel | The Brown |
| Quickbeam (Bregalad) | Ent | Fangorn | Hastiest of Ents |
| Treebeard (Fangorn) | Ent | Fangorn | Eldest of Ents |
| Shelob | Creature | Cirith Ungol | Last Child of Ungoliant |

### Quests
| Title | Status | Danger Level | Region |
|-------|--------|-------------|--------|
| Destroy the One Ring | completed | 10 | Mordor |
| Defend Helm's Deep | completed | 8 | Rohan |
| Retake Moria | failed | 9 | Moria |
| Scouring of the Shire | completed | 5 | The Shire |
| Hunt for Gollum | active | 6 | Wilderness |
| Escape the Old Forest | completed | 4 | Old Forest |
| Assault on the Black Gate | completed | 9 | Mordor |
| March of the Ents | completed | 7 | Isengard |
| Passage of the Paths of the Dead | completed | 8 | White Mountains |
| Rescue from Cirith Ungol | completed | 9 | Mordor |

### Artifacts
| Name | Type | Corrupted |
|------|------|-----------|
| The One Ring | Ring | true |
| Anduril (Flame of the West) | Sword | false |
| Narsil (shards) | Sword | false |
| Sting | Sword | false |
| Glamdring (Foe-hammer) | Sword | false |
| Orcrist (Goblin-cleaver) | Sword | false |
| Nenya (Ring of Adamant) | Ring | false |
| Vilya (Ring of Air) | Ring | false |
| Narya (Ring of Fire) | Ring | false |
| Palantir of Orthanc | Seeing Stone | true |
| Palantir of Minas Tirith | Seeing Stone | false |
| Phial of Galadriel | Light | false |
| Mithril Coat | Armor | false |
| Horn of Gondor | Horn | false |
| Red Book of Westmarch | Book | false |
| Barrow-blade (Merry's) | Dagger | false |
