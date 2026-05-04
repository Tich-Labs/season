# AGENTS.md

## Commands

```bash
# Dev server
bin/dev

# Tests (76 passing)
bin/rails test

# Lint
bundle exec rubocop --format simple
bundle exec erb_lint --lint-all --format compact  # NOT erblint

# Pre-commit order: lint -> test -> push
```

## Critical Defaults

- **Database**: PostgreSQL only. No SQLite anywhere. `db/*.sqlite3` are gitignored.
- **Brand primary**: `#933a35` (exact hex from Figma)
- **Field background**: `#EDE1D5` (NOT #F5EDE8)
- **Container**: `max-w-app mx-auto px-4` (430px max-width)
- **Tailwind classes**: Use `text-brand-primary`, NOT `text-[#933a35]`

## Gotchas

- `User#current_phase` returns nil for new users → guard with `|| "Unknown"`
- Use `current_user.onboarding_completed?` not `last_period_start.present?`
- `Admin::FeedbacksController` was deleted → use `Admin::InboxController`
- `config/master.key` is gitignored → get from team password manager
- ERB lint warnings are false positives (parser vs Ruby version)

## Asset Rules

- Filenames: lowercase, hyphens only (`season-logo.svg`)
- Use `image_tag`, never `<img src="...">`
- Assets go in `app/assets/images/`

## Error Styling

- Error text: `#933a35`
- Container: `bg-brand-error rounded-xl px-4 py-3`
- Field error: `border border-brand-primary`
- No page redirects → use inline errors with Turbo Stream

## Docs
- Figma: `docs/figma_nodes.md`
- Full instructions: `CLAUDE.md`
- Calendar preferences: `app/helpers/calendar_helper.rb`
- Internal docs: `/docs` (GitHub Pages)