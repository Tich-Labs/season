# Security Audit — Season App (Beta readiness)

**Audit date:** 1 October 2026
**Scope:** Production security posture ahead of the Big Beta, feeding the Beta Terms of Participation and Beta Privacy Notice.
**Tools run:** Brakeman `-w3`, `bundle-audit --update`.

---

## 1. Automated scan results

| Tool | Result |
|---|---|
| Brakeman `-w3` | **0 security warnings** (140 templates scanned) |
| `bundle-audit --update` | **No vulnerabilities** (1,251 advisories, DB updated 2026-09-29) |

---

## 2. Confirmed security measures (state these in the texts)

- **Encryption at rest:** Render Postgres is encrypted at rest with **AES-256**; database connections use **Render-managed TLS** certificates. (Application/field-level encryption is a separate item — see §3.)
- **Encryption in transit:** TLS enforced app-wide with HSTS (`config.force_ssl = true`, `config.assume_ssl = true`).
- **Passwords:** bcrypt hash only (`encrypted_password`, Devise). Never stored in plaintext.
- **2FA:** active on all four admin platforms — Render, GitHub, App Store Connect, Google Play Console.
- **Database access:** single admin account under Season UG (`naijeria@season.vision`, role Admin). No access through Mama Tech Limited.
- **Server region:** Frankfurt (EU Central) for both the web service and database — data stays inside the EU.
- **Backups:** Render Pro — point-in-time recovery covers 7 days; logical backups retained 7 days after creation.
- **Logs:** retention set to 30 days in Render and Sentry (decided).
- **End-user auth:** WebAuthn passkeys with PIN fallback; CSRF, CSP and rate limiting active (per prior audit).

---

## 3. Open items (do NOT overclaim in the texts)

### 🔴 HIGH
| # | Item | Detail |
|---|---|---|
| 1 | **Field-level encryption not enabled** | pgcrypto is post-launch backlog; OAuth tokens + iCloud credentials are stored in plaintext (`string` columns, no `encrypts` on `User`) — readable by anyone with database access. This is *field-level* encryption and is distinct from the **at-rest AES-256 disk encryption provided by Render, which is active**. |
| 2 | **DPAs outstanding** | Art. 28 agreements with Render, Resend, Sentry (and Google, Apple, Meta) not yet evidenced. Legally required before real user data is processed. |
| 3 | **Sentry captures PII** | `config.enable_pii = true` — error events can include IP, email and request params (possibly health data). Recommend scrubbing before the Beta. |

### 🟡 MEDIUM
| # | Item | Detail |
|---|---|---|
| 4 | **Trello receives user data** | Feedback forwards the user's email, message text and optional screenshots (screenshots may contain health data). |
| 5 | **Resend receives health content** | Reminder "morning summary" emails include cycle-phase content; Resend processes email addresses + full bodies. |
| 6 | **No IP anonymization** | Flagged in the GDPR audit. |
| 7 | **No DPO / DPIA** | Not yet appointed / conducted. |

### 🟢 LOW / housekeeping
| # | Item | Detail |
|---|---|---|
| 8 | **Backups** | Render Pro plan — PITR covers 7 days; logical backups retained 7 days after creation. |
| 9 | **Log retention** | Decided: 30 days in Render and Sentry — confirm it is applied. |
| 10 | **Stripe** | Gem present but inactive — do not list as a live processor. |

---

## 4. Third-party processors (what user data each receives)

| Provider | Purpose | User data received |
|---|---|---|
| Render | Hosting + database | All stored data (encrypted at rest, AES-256) |
| Resend | Transactional email | Email addresses + full email body (incl. health content in reminders) |
| Sentry | Error tracking | Error events with PII enabled (IP, email, request params) |
| Google / Apple / Facebook | OAuth sign-in + calendar sync | Identity + calendar access as authorised |
| APNs / Web Push | Notifications | Device tokens |
| Trello | Feedback / survey forwarding | User email + message text + optional screenshots |

---

## 5. Changes made this session

- **Retired** the outdated `app/views/legal/privacy.html.erb` (it contradicted the Beta Privacy Notice — claimed analytics usage data). No replacement created.
- **Confirmed** Render AES-256 at-rest encryption for Q5 of the Beta legal questionnaire.
- Legal controller tests pass after the deletion (21 runs, 0 failures).

*Companion doc: `docs/beta-legal-questions.html` (Beta Terms & Privacy Q&A).*
