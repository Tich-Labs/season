# Season App - Audit Checklist
## Based on Codebase Chapters (ch01_00 to ch10_68)

### App Info
- **App**: Season V2 - Women's cycle tracking PWA
- **Path**: `/Users/tichlabs/Documents/onlyCode/season`
- **Stack**: Rails 8.1.3, PostgreSQL, Hotwire (Turbo + Stimulus), Tailwind CSS
- **Status**: M1-M5, M7 complete, M6 not in scope

---

## CHAPTER 1: Foundation (ch01_00 - ch01_24) - 25 steps
### Code Quality
- [ ] Ruby version defined (.ruby-version = 3.4.7)
- [ ] Rails version current (8.1.3)
- [ ] Gemfile organized with comments
- [ ] .gitignore properly configured
- [ ] Database config uses PostgreSQL (not SQLite)
- [ ] Environment configs (development, production, test) present
- [ ] CI/CD configured (.github/workflows)
- [ ] Linting configured (Rubocop)
- [ ] ERB linting configured

### Features & Implementation
- [ ] App boots successfully (`bin/rails s`)
- [ ] Root route defined
- [ ] Basic layout with Tailwind CSS
- [ ] Asset pipeline working (Propshaft)
- [ ] Database connection working (PostgreSQL)
- [ ] Schema migrations present
- [ ] Seeds file present and working
- [ ] Master key configured (gitignored)
- [ ] Credentials encrypted properly

**Season Status**: ✅ Complete - Rails 8.1.3, PostgreSQL, Tailwind working

---

## CHAPTER 2: Core Features (ch02_01 - ch02_23) - 23 steps
### Code Quality
- [ ] Models follow naming conventions
- [ ] Controllers follow REST patterns
- [ ] Routes properly defined (resources, custom routes)
- [ ] Strong parameters used in controllers
- [ ] Callbacks kept to minimum (use service objects)
- [ ] Validations in models (presence, uniqueness, format)
- [ ] Associations properly defined (belongs_to, has_many, etc.)
- [ ] Scopes used for complex queries
- [ ] Error handling (rescue, flash messages)

### Features & Implementation
- [ ] User model with authentication
- [ ] CRUD operations for main resources
- [ ] Form helpers used (form_with, fields_for)
- [ ] Flash messages working
- [ ] Redirects after create/update/destroy
- [ ] Before_action filters for auth/login checks
- [ ] Pundit/Policy permissions (if applicable)
- [ ] Pagination (if many records)

**Season Status**: ✅ Complete - 28 controllers, 12 models, CRUD for all resources

---

## CHAPTER 3: Views & Styling (ch03_01 - ch03_16) - 16 steps
### Code Quality
- [ ] ERB templates use `<%= %>` correctly
- [ ] Partials extracted for reusable components
- [ ] No inline styles (use Tailwind classes)
- [ ] Brand colors defined in Tailwind config
- [ ] Responsive design (mobile-first)
- [ ] i18n used for all user-facing strings (`t()` helpers)
- [ ] No hardcoded English (except onboarding - known debt)
- [ ] Image_tag used (not `<img src>`)
- [ ] Asset filenames lowercase with hyphens

### Features & Implementation
- [ ] Layout renders correctly
- [ ] Navigation (top bar, burger menu) working
- [ ] Forms styled with Tailwind
- [ ] Error messages styled (inline, no redirects)
- [ ] Flash messages styled
- [ ] Buttons consistently styled
- [ ] Cards/sections use consistent padding
- [ ] Mobile container (max-w-[430px]) applied

**Season Status**: ✅ Complete - Brand colors in Tailwind config, max-w-app container, no inline styles

---

## CHAPTER 4: Authentication (ch04_01 - ch04_17) - 17 steps
### Code Quality
- [ ] Authentication concern extracted (`app/controllers/concerns/authentication.rb`)
- [ ] Sessions controller (login/logout)
- [ ] Registrations controller (sign up)
- [ ] Password recovery (Devise or custom)
- [ ] OmniAuth configured (Google, Facebook, Apple)
- [ ] Cookie-based sessions with expiry
- [ ] CSRF protection enabled
- [ ] Rate limiting configured (Rack::Attack)
- [ ] Paranoid mode (prevent account enumeration)

### Features & Implementation
- [ ] Login page works
- [ ] Sign up page works
- [ ] Logout clears session
- [ ] Remember me functionality (if applicable)
- [ ] Password reset emails sent
- [ ] OAuth callbacks working
- [ ] Protected routes redirect to login
- [ ] Admin auth gated by `User#admin?`

**Season Status**: ✅ Complete - Custom cookie auth, Devise for passwords only, OAuth built, admin gated

---

## CHAPTER 5: Mobile Development (ch05_01 - ch05_22) - 22 steps
### Code Quality
- [ ] PWA manifest present (`/manifest.json` or `pwa/` controller)
- [ ] Service worker configured (offline support)
- [ ] Viewport meta tag correct
- [ ] Mobile-first CSS (390px base, 430px max)
- [ ] Touch targets adequate (min 44px)
- [ ] Turbo Native compatible (no full page reloads)
- [ ] Camera/File upload working (if applicable)
- [ ] Push notifications configured (if applicable)
- [ ] Deep linking working (if applicable)

### Features & Implementation
- [ ] PWA installs correctly on mobile
- [ ] Offline mode works (cached assets)
- [ ] Bottom navigation working
- [ ] Safe area insets handled (iPhone X+)
- [ ] iOS/Android specific styles
- [ ] Turbo Native roadmap documented

**Season Status**: ⚠️ In Progress - PWA mobile-first (390px), Turbo Native roadmap, needs offline/SW

---

## CHAPTER 6: Advanced Features (ch06_01 - ch06_32) - 32 steps
### Code Quality
- [ ] Background jobs configured (Solid Queue)
- [ ] Job classes have descriptive names
- [ ] Active Job configured correctly
- [ ] Service objects for complex business logic
- [ ] Decorators/Presenters (if needed)
- [ ] Concerns used for shared behavior
- [ ] Caching strategy (Solid Cache, fragment caching)
- [ ] Database indexes on foreign keys
- [ ] N+1 queries eliminated (includes/preload)

### Features & Implementation
- [ ] Email reminders working (Resend)
- [ ] Background jobs processed (SendMorningRemindersJob, etc.)
- [ ] Cycle calculation service (CycleCalculatorService)
- [ ] Calendar events CRUD
- [ ] Symptom/superpower tracking
- [ ] Streaks calculation
- [ ] Multi-tenancy (if applicable)
- [ ] API endpoints (if needed)

**Season Status**: ✅ Mostly Complete - Solid Queue jobs, CycleCalculatorService, tracking features

---

## CHAPTER 7: API Development (ch07_01 - ch07_23) - 23 steps
### Code Quality
- [ ] API namespace (if applicable)
- [ ] JSON responses (jbuilder or render json:)
- [ ] API versioning (if multiple versions)
- [ ] Authentication for API (tokens)
- [ ] Rate limiting on API endpoints
- [ ] API documentation (Swagger/OpenAPI)
- [ ] Serializers (blueprinter, active_model_serializers)
- [ ] CORS configured
- [ ] Test coverage for API endpoints

### Features & Implementation
- [ ] API endpoints return correct JSON
- [ ] Authentication required for protected endpoints
- [ ] Error responses follow convention
- [ ] Pagination for collections
- [ ] Filtering/sorting (if applicable)

**Season Status**: ❌ Not applicable - Season is PWA with Hotwire, no API needed currently

---

## CHAPTER 8: Integration (ch08_00 - ch08_22) - 23 steps
### Code Quality
- [ ] Payment gateway configured (Stripe wired, not active)
- [ ] Email delivery (Resend adapter)
- [ ] Error tracking (Sentry configured)
- [ ] Analytics (if applicable)
- [ ] Webhooks handled (Stripe, etc.)
- [ ] OAuth providers configured
- [ ] Environment variables documented
- [ ] Secrets in credentials or ENV
- [ ] Third-party gems configured correctly

### Features & Implementation
- [ ] Emails delivered (ReminderMailer, SupportMailer)
- [ ] Stripe ready for post-launch
- [ ] Sentry wired (needs SENTRY_DSN on Render)
- [ ] Resend API key set on Render
- [ ] OAuth credentials set on Render (TODO)
- [ ] Webhooks verified (if applicable)

**Season Status**: ⚠️ Partial - Resend working, Stripe wired, Sentry not wired, OAuth needs credentials

---

## CHAPTER 9: Testing (ch09_01 - ch09_09) - 9 steps
### Code Quality
- [ ] Test framework configured (Minitest - 76 tests passing)
- [ ] Model tests (validations, associations)
- [ ] Controller tests (responses, redirects)
- [ ] Integration tests (user flows)
- [ ] System tests (Capybara, if applicable)
- [ ] Test coverage > 80%
- [ ] Factories/fixtures defined
- [ ] Mocks/stubs used appropriately
- [ ] CI runs tests automatically

### Features & Implementation
- [ ] `bin/rails test` passes (76 tests)
- [ ] Critical paths tested (login, signup, tracking)
- [ ] Edge cases tested (nil values, invalid input)
- [ ] Mailer tests present
- [ ] Job tests present

**Season Status**: ✅ Complete - 76 tests passing, Minitest setup

---

## CHAPTER 10: Production (ch10_01 - ch10_68) - 68 steps
### Code Quality
- [ ] Deployment platform configured (Render)
- [ ] Build script present (`bin/render-build.sh`)
- [ ] Production database (PostgreSQL on Render)
- [ ] Assets precompiled in build
- [ ] Logs configured (stdout for PaaS)
- [ ] Error pages customized (404, 500)
- [ ] Health check endpoint (`/up`)
- [ ] Security headers (CSP, HSTS)
- [ ] Config.hosts set (DNS rebinding protection)

### Features & Implementation
- [ ] App deploys successfully to Render
- [ ] Auto-deploy on push to main
- [ ] Database migrations run on deploy
- [ ] Assets serve correctly in production
- [ ] Error tracking works (Sentry)
- [ ] Email delivery works in production
- [ ] HTTPS enforced
- [ ] Performance monitoring (if applicable)

**Season Status**: ⚠️ Partial - Render deployed, needs config.hosts, Sentry DSN, CSP enforcement

---

## SUMMARY STATUS (Season App)

| Chapter | Topic | Status | Completion |
|---------|--------|--------|------------|
| 1 | Foundation | ✅ Complete | 95% |
| 2 | Core Features | ✅ Complete | 100% |
| 3 | Views & Styling | ✅ Complete | 95% |
| 4 | Authentication | ✅ Complete | 90% |
| 5 | Mobile | ⚠️ In Progress | 60% |
| 6 | Advanced | ✅ Mostly Complete | 85% |
| 7 | API | ❌ Not Applicable | N/A |
| 8 | Integration | ⚠️ Partial | 70% |
| 9 | Testing | ✅ Complete | 100% |
| 10 | Production | ⚠️ Partial | 75% |

### Critical Pre-Launch Items (from README)
- [ ] OAuth credentials on Render (Google, Facebook, Apple)
- [ ] `config.hosts` uncomment (DNS rebinding protection)
- [ ] `config.load_defaults 8.1` run (currently 8.0 defaults)
- [ ] Devise `config.paranoid = true` (prevent account enumeration)
- [ ] CSP enforcement (flip `report_only` to `false`)
- [ ] Active Storage switch to S3/R2 (avatars lost on redeploy)
- [ ] Sentry `SENTRY_DSN` set on Render
- [ ] Rack::Attack on login endpoints

### Known Issues
1. Burger menu text labels not using `t()` (hardcoded English)
2. Onboarding screens have hardcoded English strings
3. OAuth credentials not yet set on Render
