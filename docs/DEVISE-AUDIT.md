# Devise Authentication Audit — Season App

**Audit Date:** 28 April 2026  
**Updated:** 2 May 2026  
**Context:** Full repo audit for Devise authentication integrity

---

## Executive Summary

**Status: ✅ FUNCTIONAL & STANDARD**

The app uses a hybrid architecture:
- **Devise** for underlying functionality (password reset tokens, OmniAuth, ORM integration, **email confirmation**)
- **Custom controllers** for sign in/sign up flows (preserves Season UI)

The Devise audit recommendations have been implemented fully.

---

## A. Devise Core Integrity

### Model Configuration (User)
```ruby
devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable,
  :confirmable,
  :omniauthable, omniauth_providers: [:google_oauth2, :facebook, :apple]
```
- ✅ All modules properly configured
- ✅ `:confirmable` fully implemented (not bypassed)
- ✅ `devise_parameter_sanitizer` configured in `ApplicationController`

### Routes
```ruby
devise_for :users,
  controllers: {
    passwords: "passwords",
    confirmations: "confirmations"
  },
  skip: [:sessions],  # Custom sessions used instead
  omniauth_providers: [:google_oauth2, :facebook, :apple]
```
- ✅ Sessions skipped (custom controller handles login)
- ✅ Passwords routed to custom controller
- ✅ Confirmations routed to custom `ConfirmationsController`
- ✅ OmniAuth configured

### Database
- ✅ Schema has Devise columns: `encrypted_password`, `reset_password_token`, `reset_password_sent_at`, `confirmation_token`, `confirmed_at`, etc.

---

## B. View Customization

### Custom Views (Not Devise Default)
| View | Location |
|------|----------|
| Login form | `app/views/sessions/new.html.erb` |
| Signup form | `app/views/registrations/new.html.erb` |
| Check email (after signup) | `app/views/registrations/check_email.html.erb` |
| Password reset | `app/views/passwords/` |

### Devise Views (Minimal)
- `app/views/devise/mailer/confirmation_instructions.html.erb`
- `app/views/devise/mailer/reset_password_instructions.html.erb`
- `app/views/devise/shared/_error_messages.html.erb`

✅ Only 4 Devise views - well maintained

---

## C. Custom Controllers

### SessionsController
```ruby
class SessionsController < ApplicationController
  # Custom login - NOT using Devise sessions
  # Uses: User#valid_password? + custom login() method
  # Rate limiting: 5 attempts per 15 min (disabled in development)
  # ✅ Enforces email confirmation check before login
end
```
**Status:** ✅ Working. Provides rate limiting Devise doesn't have. Blocks unconfirmed users.

### RegistrationsController
```ruby
class RegistrationsController < ApplicationController
  # Custom signup - NOT using Devise registrations
  # After save → redirects to check_email instead of auto-login
  # OmniAuth users: skip_confirmation! (provider already verified email)
end
```
**Status:** ✅ Working. Properly implements email confirmation flow.

### ConfirmationsController (NEW)
```ruby
class ConfirmationsController < Devise::ConfirmationsController
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    if resource.errors.empty?
      login(resource)
      redirect_to after_sign_in_path
    else
      redirect_to new_user_confirmation_path, alert: "Link expired or already used."
    end
  end
end
```
**Status:** ✅ New. Auto-logs in user after email confirmation, redirects to onboarding.

### PasswordsController
```ruby
class PasswordsController < ApplicationController
  # Uses Devise internally: User#send_reset_password_instructions
  # Good implementation
end
```
**Status:** ✅ Best example of proper Devise integration

---

## D. User Journey (Updated)

### New Email/Password Sign Up
```
Sign up → save → /registration/check_email
                 "Check your inbox — click to activate"
                      ↓
              Email: "Confirm my account" button
                      ↓
              GET /users/confirmation?token=xxx
              ConfirmationsController#show
              → confirm_by_token(token)
              → login(user)
              → onboarding step 1 → ... → /calendar
```

### OmniAuth (Google/Apple/Facebook)
- Bypasses email confirmation — provider already verified the email
- `skip_confirmation!` is called automatically in `User.find_or_create_from_oauth`

### Unconfirmed User Edge Case
If someone registered but never confirmed, then tries to log in:
- Password is correct but `confirmed?` is false
- Shows the branded `:unconfirmed` error with an inline "resend confirmation email" link pointing to `new_user_confirmation_path`

### Expired/Reused Confirmation Link
- Redirected to `/users/confirmation/new` (Devise's resend page) with an alert message

---

## E. Risk Assessment (Updated)

| Issue | Severity | Status |
|-------|----------|--------|
| Missing `devise_parameter_sanitizer` | 🟡 MEDIUM | ✅ FIXED |
| `:confirmable` enabled but bypassed | 🟡 MEDIUM | ✅ FIXED — fully implemented |
| Rate limiting on IP not user | 🟡 MEDIUM | ✅ Acceptable (custom sessions) |
| Custom sessions replace Devise | 🟡 MEDIUM | ✅ Working well |

---

## F. Cleanup Opportunities (Completed)

| Action | Effort | Status |
|--------|--------|--------|
| Add `devise_parameter_sanitizer` | 30 min | ✅ DONE |
| Resolve `:confirmable` (use or remove) | 1 hr | ✅ DONE — fully implemented |
| Create `ConfirmationsController` | 30 min | ✅ DONE |
| Create `check_email.html.erb` view | 15 min | ✅ DONE |
| Wire confirmation routes | 15 min | ✅ DONE |
| Update `RegistrationsController` flow | 30 min | ✅ DONE |
| Restore `confirmed?` check in `SessionsController` | 15 min | ✅ DONE |

---

## G. What's Working

| Component | Status |
|-----------|--------|
| Password reset | ✅ |
| Email confirmation flow | ✅ |
| OmniAuth (Google, FB, Apple) | ✅ |
| User model Devise modules | ✅ |
| Custom login with rate limiting | ✅ |
| Custom signup → check email | ✅ |
| Auto-login after confirmation | ✅ |
| Session management | ✅ |
| `devise_parameter_sanitizer` | ✅ |

---

## H. Playwright Auth Tests

| Test File | Coverage | Status |
|-----------|----------|--------|
| `tests/auth/sign-up.spec.js` | Valid sign up, duplicate email, password mismatch | 🟡 Partial |
| `tests/auth/sign-in.spec.js` | Valid login, wrong password, non-existent email, redirect if authenticated | ✅ Passing |
| `tests/auth/sign-out.spec.js` | Sign out, protected page access after sign out | 🟡 Partial |
| `tests/auth/password-reset.spec.js` | Forgot password page, submit request, done page | ✅ Passing |

---

## I. Feedback Button Update (2 May 2026)

### What Changed
| File | Change |
|------|--------|
| `app/views/tracking/index.html.erb` | Feedback button now calls `feedback-modal#openWithType` directly (removed wrapping `<div data-controller="feedback-modal">`) |
| `app/views/layouts/launch.html.erb` | Added `<%= render "shared/feedback_modal" %>` so modal is available on tracking page |
| `app/javascript/controllers/feedback_modal_controller.js` | `window.openFeedbackModal` function available for programmatic opening with type |

### How It Works
- Tracking page has a **feedback button** with `data-type="feedback"` and `data-action="click->feedback-modal#openWithType"`
- Clicking opens the feedback modal with **Feedback** tab pre-selected (heading: "Share your feedback", placeholder: "What's on your mind?")
- User can switch between **Feedback**, **Bug Report**, and **Support** tabs
- Modal renders from `shared/_feedback_modal.html.erb` with Stimulus controller `feedback-modal`

---

## J. Tracking Page Audit (2 May 2026)

### What's Implemented
| Component | Status | Details |
|-----------|--------|---------|
| Cycle wheel (SVG donut) | ✅ | Shows current phase, day needle, phase colours |
| Cycle day strip | ✅ | 6 past + 6 future days, highlights "Today" |
| Self Analysis heading | ✅ | Month name, streak badge |
| Navigation cards | ✅ | My Symptoms, My Superpower links |
| Period card | ✅ | Last period start, edit/update button |
| Feedback button | ✅ | Opens modal with pre-selected type |

### TrackingController Endpoints
| Action | Route | Purpose |
|--------|-------|---------|
| `index` | `GET /tracking` | Main tracking page with cycle data |
| `create` | `POST /tracking` | Log period start, create cycle entry |
| `period` | `GET /tracking/period` | Period date picker page |
| `period_update` | `PATCH /tracking` | Update period start date |

### Feedback Flow
```
Tracking page → click "Feedback" button
         ↓
    Modal opens (Feedback tab active)
         ↓
    User fills message, attaches screenshot/audio (optional)
         ↓
    POST /feedbacks → Feedback#create
         ↓
    Turbo Stream: replace modal with success/error
         ↓
    After save: TrelloMailer job enqueued → Trello card created
```

**Feedback Model:** `belongs_to :user`, `has_one_attached :media`, enum `:type` (feedback/bug_report/support)

---

*Audit conducted: 28 April 2026*  
*Updated: 2 May 2026 — confirmable fully implemented, all audit recommendations complete, feedback button wired, tracking page audited*
