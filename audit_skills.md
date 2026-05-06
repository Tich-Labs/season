# Audit Skills for Season App
## Based on Codebase Chapters (ch01_00 to ch10_68)

These skills define reusable audit tasks that can be run against the Season app.
Use the Task tool or Claude Code to invoke these skills.

---

## SKILL: audit-chapter-1
**Description**: Audit Chapter 1 - Foundation (Rails setup, config, basic structure)
**Agent Type**: explore

**Prompt**:
```
Audit the Season app (/Users/tichlabs/Documents/onlyCode/season) against Chapter 1 Foundation checklist.

Check the following:

1. **Code Quality**
   - Read `.ruby-version` - should be 3.4.7
   - Read `Gemfile` - Rails 8.1.3 should be present
   - Check `.gitignore` - should have standard Rails entries
   - Check `config/database.yml` - should use PostgreSQL (not SQLite)
   - Check `config/environments/*.rb` - all three environments present
   - Check `.github/workflows/` - CI/CD configured
   - Run `bundle exec rubocop --format simple` - should pass
   - Check `bin/rails s` boots successfully

2. **Features**
   - Root route defined in `config/routes.rb`
   - Application layout exists (`app/views/layouts/application.html.erb`)
   - Tailwind configured (`config/tailwind.config.js`)
   - Assets pipeline (Propshaft) configured
   - Database connection works (check `db/schema.rb`)
   - Migrations present in `db/migrate/`
   - Seeds file present (`db/seeds.rb`)
   - `config/master.key` is gitignored
   - Credentials work (`rails credentials:edit`)

Return a report with ✅ Pass, ⚠️ Warning, or ❌ Fail for each item.
```

---

## SKILL: audit-chapter-2
**Description**: Audit Chapter 2 - Core Features (Models, controllers, CRUD)
**Agent Type**: explore

**Prompt**:
```
Audit the Season app (/Users/tichlabs/Documents/onlyCode/season) against Chapter 2 Core Features checklist.

Check the following:

1. **Code Quality**
   - List all models in `app/models/` - follow naming conventions
   - List all controllers in `app/controllers/` - follow REST patterns
   - Read `config/routes.rb` - proper routing (resources, custom routes)
   - Check controllers use `strong_parameters`
   - Check models have validations (presence, uniqueness, format)
   - Check model associations (belongs_to, has_many, etc.)
   - Check for service objects (app/services/) - complex logic extracted
   - Check error handling (rescue, flash messages)

2. **Features**
   - User model exists with authentication
   - CRUD operations work for main resources (CycleEntry, SymptomLog, etc.)
   - Form helpers used (`form_with`, `fields_for`)
   - Flash messages appear correctly
   - Redirects after create/update/destroy
   - Before_action filters for auth checks
   - Pagination if many records

Count total controllers and models. List any missing CRUD operations.

Return a report with ✅ Pass, ⚠️ Warning, or ❌ Fail for each item.
```

---

## SKILL: audit-chapter-3
**Description**: Audit Chapter 3 - Views & Styling (Tailwind, ERB, i18n)
**Agent Type**: explore

**Prompt**:
```
Audit the Season app (/Users/tichlabs/Documents/onlyCode/season) against Chapter 3 Views & Styling checklist.

Check the following:

1. **Code Quality**
   - Scan ERB files for inline styles (`style="`) - should NOT exist except dynamic phase colors
   - Check `config/tailwind.config.js` - brand colors defined as CSS variables
   - Check views use `text-brand-primary` NOT `text-[#933a35]`
   - Check container uses `max-w-app mx-auto px-4` (430px max-width)
   - Check for `t()` helpers in user-facing strings (grep for hardcoded English)
   - Check asset filenames: lowercase, hyphens only
   - Check `image_tag` used (not `<img src>`)
   - Check responsive design (mobile-first, 390px base)

2. **Features**
   - Layout renders correctly
   - Navigation (top bar, burger menu) working
   - Forms styled with Tailwind
   - Error messages styled inline (not page redirects)
   - Buttons consistently styled
   - Cards/sections use consistent padding

Run a grep search for:
- `style="` in app/views/
- Hardcoded English strings (TODO: list specific words)
- `image_tag` vs `<img` usage

Return a report with ✅ Pass, ⚠️ Warning, or ❌ Fail for each item.
```

---

## SKILL: audit-chapter-4
**Description**: Audit Chapter 4 - Authentication (Auth flows, OAuth, security)
**Agent Type**: explore

**Prompt**:
```
Audit the Season app (/Users/tichlabs/Documents/onlyCode/season) against Chapter 4 Authentication checklist.

Check the following:

1. **Code Quality**
   - Read `app/controllers/concerns/authentication.rb` - exists and properly implemented
   - Read `app/controllers/sessions_controller.rb` - login/logout logic
   - Read `app/controllers/registrations_controller.rb` - sign up logic
   - Check Devise configuration in `config/initializers/devise.rb`
   - Check OmniAuth configured (Google, Facebook, Apple)
   - Check cookie-based sessions with expiry (7 days)
   - Check CSRF protection enabled
   - Check if Rack::Attack configured for rate limiting

2. **Features**
   - Login page works (`/session/new`)
   - Sign up page works (`/registration/new`)
   - Logout clears session
   - Password recovery emails sent (Devise)
   - OAuth callbacks working (routes exist)
   - Protected routes redirect to login
   - Admin auth gated by `User#admin?`

Read CLAUDE.md sections on Auth flow requirements.
Check `config/initializers/omniauth.rb` exists or is in devise.rb.

Return a report with ✅ Pass, ⚠️ Warning, or ❌ Fail for each item.
```

---

## SKILL: audit-chapter-5
**Description**: Audit Chapter 5 - Mobile PWA (PWA manifest, service worker, Turbo Native)
**Agent Type**: explore

**Prompt**:
```
Audit the Season app (/Users/tichlabs/Documents/onlyCode/season) against Chapter 5 Mobile Development checklist.

Check the following:

1. **Code Quality**
   - Check for PWA manifest (`app/views/pwa/` or `public/manifest.json`)
   - Check for service worker (`app/javascript/service-worker.js` or similar)
   - Read `app/views/layouts/application.html.erb` - viewport meta tag
   - Check mobile-first CSS (390px base, 430px max-width)
   - Check touch targets (min 44px)
   - Check Turbo compatibility (no full page reloads)
   - Check `app/controllers/pwa_controller.rb` exists

2. **Features**
   - PWA installs correctly on mobile (manifest valid)
   - Offline mode works (service worker caches assets)
   - Bottom navigation working
   - Safe area insets handled (iPhone X+)
   - Turbo Native roadmap documented (check README or docs)

Check `app/assets/images/` for PWA icons (192x192, 512x512).
Check `docs/` for Turbo Native documentation.

Return a report with ✅ Pass, ⚠️ Warning, or ❌ Fail for each item.
```

---

## SKILL: audit-chapter-6
**Description**: Audit Chapter 6 - Advanced Features (Jobs, services, caching)
**Agent Type**: explore

**Prompt**:
```
Audit the Season app (/Users/tichlabs/Documents/onlyCode/season) against Chapter 6 Advanced Features checklist.

Check the following:

1. **Code Quality**
   - List jobs in `app/jobs/` - Solid Queue configured
   - Read `app/services/cycle_calculator_service.rb` - business logic extracted
   - Check `config/cache_store` - Solid Cache configured
   - Check database indexes in migrations (foreign keys, unique indexes)
   - Check for N+1 queries (look for includes/preload)
   - Check concerns in `app/models/concerns/` (shared behavior)
   - Check caching strategy (fragment caching if applicable)

2. **Features**
   - Email reminders working (SendMorningRemindersJob, etc.)
   - Background jobs processed (check Solid Queue config)
   - Cycle calculation service works (CycleCalculatorService)
   - Calendar events CRUD works
   - Symptom/superpower tracking works
   - Streaks calculation works

Run `bin/rails jobs:work` or check Solid Queue config.
Check `config/initializers/solid_queue.rb` exists.

Return a report with ✅ Pass, ⚠️ Warning, or ❌ Fail for each item.
```

---

## SKILL: audit-chapter-8
**Description**: Audit Chapter 8 - Integration (Payments, email, error tracking)
**Agent Type**: explore

**Prompt**:
```
Audit the Season app (/Users/tichlabs/Documents/onlyCode/season) against Chapter 8 Integration checklist.

Check the following:

1. **Code Quality**
   - Read `Gemfile` - Stripe gem present (wired but not active)
   - Read `config/initializers/resend.rb` - Resend configured
   - Check Sentry configuration (`config/initializers/sentry.rb`)
   - Check environment variables documented (RESEND_API_KEY, etc.)
   - Check secrets in credentials (`rails credentials:edit`)
   - Check OAuth providers configured in devise.rb
   - Check webhook endpoints (if applicable)

2. **Features**
   - Emails delivered via Resend (ReminderMailer, SupportMailer)
   - Stripe ready for post-launch
   - Sentry wired (needs SENTRY_DSN on Render)
   - Resend API key set on Render (or in credentials)
   - OAuth credentials set on Render (TODO item)

Check Render environment variables (if accessible).
Read `config/deploy/` or `render.yaml` for environment config.

Return a report with ✅ Pass, ⚠️ Warning, or ❌ Fail for each item.
```

---

## SKILL: audit-chapter-9
**Description**: Audit Chapter 9 - Testing (Test coverage, Minitest)
**Agent Type**: explore

**Prompt**:
```
Audit the Season app (/Users/tichlabs/Documents/onlyCode/season) against Chapter 9 Testing checklist.

Check the following:

1. **Code Quality**
   - Run `bin/rails test` - should pass (76 tests)
   - Check `test/` directory structure (models, controllers, integration)
   - Check test coverage (if simplecov configured)
   - Check fixtures/factories in `test/fixtures/`
   - Check for mocks/stubs usage

2. **Features**
   - Model tests present (validations, associations)
   - Controller tests present (responses, redirects)
   - Integration tests present (user flows)
   - Mailer tests present
   - Job tests present

Run the test command and capture output.
Check if `test/system/` exists for system tests.

Return a report with ✅ Pass, ⚠️ Warning, or ❌ Fail for each item.
```

---

## SKILL: audit-chapter-10
**Description**: Audit Chapter 10 - Production (Deployment, security, monitoring)
**Agent Type**: explore

**Prompt**:
```
Audit the Season app (/Users/tichlabs/Documents/onlyCode/season) against Chapter 10 Production checklist.

Check the following:

1. **Code Quality**
   - Read `render.yaml` or `bin/render-build.sh` - build script present
   - Check `config/environments/production.rb` - settings correct
   - Check `config.hosts` - should be uncommented (DNS rebinding protection)
   - Check CSP config in production.rb - should enforce (not report_only)
   - Check `config/initializers/rack_attack.rb` - rate limiting
   - Check health check endpoint (`/up`)
   - Check custom error pages (404, 500)

2. **Features**
   - App deploys successfully to Render
   - Auto-deploy on push to main
   - Database migrations run on deploy
   - Assets precompiled in build
   - HTTPS enforced
   - Error tracking works (Sentry needs DSN)

Read README.md "What's Left Before Launch" section.
Check `config/environments/production.rb` for `config.hosts` setting.

Return a report with ✅ Pass, ⚠️ Warning, or ❌ Fail for each item.
```

---

## SKILL: audit-security
**Description**: Comprehensive security audit (combines ch04, ch10 security items)
**Agent Type**: explore

**Prompt**:
```
Run a comprehensive security audit on the Season app (/Users/tichlabs/Documents/onlyCode/season).

Check the following security items:

1. **Authentication & Authorization**
   - Session expiry (7 days) configured
   - Password complexity requirements
   - Devise paranoid mode (prevent account enumeration)
   - OAuth state parameter validation

2. **Rate Limiting**
   - Rack::Attack configured on login endpoints
   - Rate limiting on launch-signup endpoints
   - IP spoofing protection

3. **CSP & Headers**
   - Content Security Policy enforced (not report_only)
   - HSTS enabled
   - X-Frame-Options set
   - X-Content-Type-Options set

4. **Data Protection**
   - Credentials encrypted (not in git)
   - Master key gitignored
   - Sensitive data not in logs
   - HTTPS enforced in production

5. **Input Validation**
   - Strong parameters used
   - SQL injection prevention (ActiveRecord)
   - XSS prevention (ERB auto-escaping)
   - CSRF protection enabled

Read `config/initializers/security.rb` or similar.
Check `config/environments/production.rb` for security headers.

Return a detailed security report with severity levels (High/Medium/Low).
```

---

## SKILL: audit-pre-launch
**Description**: Check all pre-launch items from README.md
**Agent Type**: explore

**Prompt**:
```
Check all pre-launch items for the Season app (/Users/tichlabs/Documents/onlyCode/season).

From README.md "What's Left Before Launch" table:

1. **OAuth credentials on Render** (High)
   - Check if Google, Facebook, Apple credentials are set in Render dashboard
   - Check `config/initializers/devise.rb` for OmniAuth config

2. **config.hosts uncomment** (High)
   - Read `config/environments/production.rb`
   - Check if `config.hosts` is commented out

3. **Rack::Attack on login** (High)
   - Check if `config/initializers/rack_attack.rb` exists
   - Check if rate limiting is applied to login endpoints

4. **config.load_defaults 8.1** (High)
   - Read `config/application.rb`
   - Check if still on 8.0 defaults

5. **Devise config.paranoid = true** (Medium)
   - Read `config/initializers/devise.rb`
   - Check paranoid setting

6. **CSP enforcement** (Medium)
   - Check `config/environments/production.rb`
   - Check if `report_only` is flipped to `false`

7. **Active Storage S3/R2** (Medium)
   - Check `config/storage.yml`
   - Check if production uses local disk

8. **Sentry DSN on Render** (Medium)
   - Check if `SENTRY_DSN` is set in Render
   - Check `config/initializers/sentry.rb`

9. **Stripe paywall** (Low)
   - Check if Stripe is wired for post-launch

Return a checklist with ✅ Done, ⚠️ TODO, or ❌ Not Started for each item.
```

---

## Usage Examples

### Run Individual Chapter Audit
Use the Task tool with the `audit-chapter-X` skill:

```
Task(
  description: "Audit Chapter 3",
  prompt: "<paste audit-chapter-3 prompt here>",
  subagent_type: "explore"
)
```

### Run All Audits
Create a master audit task that runs all skills sequentially.

### Run Security Audit
```
Task(
  description: "Security Audit",
  prompt: "<paste audit-security prompt here>",
  subagent_type: "explore"
)
```

### Run Pre-Launch Check
```
Task(
  description: "Pre-Launch Check",
  prompt: "<paste audit-pre-launch prompt here>",
  subagent_type: "explore"
)
```
