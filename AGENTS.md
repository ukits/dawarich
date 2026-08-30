# Repository Guidelines

## Project Structure & Module Organization
Dawarich is a Rails 8 monolith. Controllers, models, jobs, services, policies, and Stimulus/Turbo JS live in `app/`, while shared POROs sit in `lib/`. Configuration, credentials, and cron/Sidekiq settings live in `config/`; API documentation assets are in `swagger/`. Database migrations and seeds live in `db/`, Docker tooling sits in `docker/`, and docs or media live in `docs/` and `screenshots/`. Runtime artifacts in `storage/`, `tmp/`, and `log/` stay untracked.

## Architecture & Key Services
The stack pairs Rails 8 with PostgreSQL + PostGIS, Redis-backed Sidekiq, Devise/Pundit, Tailwind + DaisyUI, and Leaflet/Chartkick. Imports, exports, sharing, and trip analytics lean on PostGIS geometries plus workers, so queue anything non-trivial instead of blocking requests.

## Build, Test, and Development Commands
- `docker compose -f docker/docker-compose.yml up` — launches the full stack for smoke tests.
- `bundle exec rails db:prepare` — create/migrate the PostGIS database.
- `bundle exec bin/dev` and `bundle exec sidekiq` — start the web/Vite/Tailwind stack and workers locally.
- `make test` — runs Playwright (`npx playwright test e2e --workers=1`) then `bundle exec rspec`.
- `bundle exec rubocop` / `npx prettier --check app/javascript` — enforce formatting before commits.

## Coding Style & Naming Conventions
Use two-space indentation, snake_case filenames, and CamelCase classes. Keep Stimulus controllers under `app/javascript/controllers/*_controller.ts` so names match DOM `data-controller` hooks. Prefer service objects in `app/services/` for multi-step imports/exports, and let migrations named like `202405061210_add_indexes_to_events` manage schema changes. Follow Tailwind ordering conventions and avoid bespoke CSS unless necessary.

## Testing Guidelines
RSpec mirrors the app hierarchy inside `spec/` with files suffixed `_spec.rb`; rely on FactoryBot/FFaker for data, WebMock for HTTP, and SimpleCov for coverage. Browser journeys live in `e2e/` and should use `data-testid` selectors plus seeded demo data to reset state. Run `make test` before pushing and document intentional gaps when coverage dips.

## Commit & Pull Request Guidelines
Write short, imperative commit subjects (`Add globe_projection setting`) and include the PR/issue reference like `(#2138)` when relevant. Target `dev`, describe migrations, configs, and verification steps, and attach screenshots or curl examples for UI/API work. Link related Discussions for larger changes and request review from domain owners (imports, sharing, trips, etc.).

## Security & Configuration Tips
Start from `.env.example` or `.env.template` and store secrets in encrypted Rails credentials; never commit files from `gps-env/` or real trace data. Rotate API keys, scrub sensitive coordinates in fixtures, and use the synthetic traces in `db/seeds.rb` when demonstrating imports.

## Fork · Upstream Sync (ukits/dawarich)

This tree is a **fork** of Freika/dawarich with local features tracked in `FORK_CHANGES.md`.

When the user asks to pull / merge / sync / upgrade **upstream** (Freika/dawarich), or to re-apply fork changes onto a newer Dawarich version:

1. **Do not invent a new merge strategy.** Follow `docs/upstream-sync/PROCESS.md`.
2. Read `FORK_CHANGES.md` (feature catalog `Fxx`) and the open cycle under `docs/upstream-sync/cycles/` (or create a new cycle file from the template in PROCESS).
3. Work on `sync/<target-version>` from upstream (`bash bin/setup_upstream_sync.sh <version>`), not a blind merge into `master`.
4. Re-apply **one feature at a time** (intent re-implementation, not mechanical cherry-pick). Log decisions in the cycle file; update feature status in `FORK_CHANGES.md`.
5. Overview: `docs/upstream-sync/README.md`.
