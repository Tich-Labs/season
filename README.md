# Season

Women's health tracking app — Rails 8 + Hotwire + Turbo Native (iOS).

**Live**: [seasonv2.onrender.com](https://seasonv2.onrender.com)

## Stack

- **Backend**: Ruby 3.4, Rails 8, PostgreSQL
- **Frontend**: Tailwind CSS, Stimulus, Turbo
- **Mobile**: Hotwire Native iOS (Turbo Native)
- **Hosting**: Render (free tier)
- **Queue**: SolidQueue (in-process with Puma)

## Setup

```bash
bin/setup
bin/dev
```

Requires Ruby 3.4+, PostgreSQL, and the master key (`config/master.key`).

## Branching Workflow

| Branch | Purpose |
|--------|---------|
| `main` | Production — protected, requires PR + approval |
| `dev` | Development — all feature work starts here |

**To contribute**:

```bash
git checkout dev
git checkout -b feature/your-feature
# ... make changes ...
git push -u origin feature/your-feature
# Open a PR from feature/your-feature → dev
# Once merged, open a PR from dev → main
```

- Never commit directly to `main`
- All changes go through `dev` first
- PRs to `main` require at least 1 approval and passing checks

## Commands

```bash
bin/dev                   # Start dev server
bin/rails test            # Run tests (166 tests)
bundle exec rubocop       # Ruby lint
npx standard app/javascript/controllers/  # JS lint
```

Pre-commit hook runs: lint → test → push.

## Docs

- `AGENTS.md` — critical defaults, gotchas, iOS best practices
- `docs/` — Figma notes, iOS integration, audit system
- `ios/SeasonApp/` — Xcode project for iOS Turbo Native app
