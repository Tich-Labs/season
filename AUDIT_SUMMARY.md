# Season App - Audit System Summary

**Version:** 1.0 (2026-05-06)  
**Updated:** 2026-05-06 09:05  
**Status:** Active

## Overview
This audit system allows you to systematically check your Season app against the **259-step codebase** (ch01_00 to ch10_68) located in `/Users/tichlabs/Documents/codebase/code/`.

---

## Files Created

| File | Location | Purpose |
|------|----------|---------|
| `guide.html` | `/Users/tichlabs/Documents/codebase/guide.html` | Book-style HTML guide with chapter navigation & audit section |
| `GUIDE.md` | `/Users/tichlabs/Documents/codebase/GUIDE.md` | Markdown version of the guide |
| `audit_checklist.md` | `/Users/tichlabs/Documents/onlyCode/season/audit_checklist.md` | Detailed checklist for all 10 chapters |
| `audit_skills.md` | `/Users/tichlabs/Documents/onlyCode/season/audit_skills.md` | Agent skills (prompts for Claude Code/OpenCode) |
| `audit_runner.sh` | `/Users/tichlabs/Documents/onlyCode/season/audit_runner.sh` | Bash script for quick audits |

---

## Season App Info

| Attribute | Value |
|-----------|-------|
| **Name** | Season V2 |
| **Type** | Women's cycle tracking PWA |
| **Path** | `/Users/tichlabs/Documents/onlyCode/season` |
| **Stack** | Rails 8.1.3, PostgreSQL, Hotwire (Turbo + Stimulus), Tailwind CSS |
| **Status** | M1-M5, M7 complete, M6 not in scope |

---

## How to Use the Audit System

### Method 1: Quick Audit Runner (Bash)
```bash
cd /Users/tichlabs/Documents/onlyCode/season

# Run all chapter audits
./audit_runner.sh all

# Run single chapter audit
./audit_runner.sh chapter1   # or ./audit_runner.sh 1
./audit_runner.sh chapter3   # or ./audit_runner.sh 3

# Run security audit
./audit_runner.sh security

# Check pre-launch items
./audit_runner.sh pre-launch
```

### Method 2: Agent Skills (Claude Code / OpenCode)
Use the Task tool with skills from `audit_skills.md`:

```
Task(
  description: "Audit Chapter 3",
  prompt: "<copy prompt from audit_skills.md - audit-chapter-3>",
  subagent_type: "explore"
)
```

Available skills:
- `audit-chapter-1` through `audit-chapter-6`
- `audit-chapter-8` through `audit-chapter-10`
- `audit-security` (comprehensive security check)
- `audit-pre-launch` (checks README.md TODOs)

### Method 3: Read Checklists Manually
Open these files in your editor:
- `audit_checklist.md` - Full checklist with ✅/⚠️/❌ items
- `audit_skills.md` - Copy-paste prompts for agents
- `README.md` - Season status & "What's Left Before Launch"

---

## Chapter Audit Summary (Season App)

| Chapter | Topic | Status | Completion | Priority Items |
|---------|--------|--------|------------|-----------------|
| 1 | Foundation | ✅ Complete | 95% | - |
| 2 | Core Features | ✅ Complete | 100% | - |
| 3 | Views & Styling | ✅ Complete | 95% | Check hardcoded English in burger menu |
| 4 | Authentication | ✅ Complete | 90% | Devise paranoid mode (medium priority) |
| 5 | Mobile PWA | ⚠️ In Progress | 60% | PWA manifest, service worker, offline mode |
| 6 | Advanced Features | ✅ Mostly Complete | 85% | - |
| 7 | API Development | ❌ Not Applicable | N/A | Season is PWA (no API needed) |
| 8 | Integration | ⚠️ Partial | 70% | OAuth credentials, Sentry DSN |
| 9 | Testing | ✅ Complete | 100% | 76 tests passing |
| 10 | Production | ⚠️ Partial | 75% | config.hosts, CSP, Rack::Attack |

---

## Critical Pre-Launch Items (HIGH Priority)

From `README.md`:

1. **OAuth credentials on Render** (Google, Facebook, Apple) - **HIGH**
2. **`config.hosts` uncomment** (DNS rebinding protection) - **HIGH**
3. **Rack::Attack on login endpoints** (rate limiting) - **HIGH**
4. **`config.load_defaults 8.1`** (run `bin/rails app:update`) - **HIGH**

## Medium Priority Items

5. **Devise `config.paranoid = true`** (prevent account enumeration)
6. **CSP enforcement** (flip `report_only` to `false`)
7. **Active Storage switch to S3/R2** (avatars lost on redeploy)
8. **Sentry `SENTRY_DSN` on Render** (error tracking)

---

## Audit Workflow Example

```bash
# Step 1: Run all audits to see current status
cd /Users/tichlabs/Documents/onlyCode/season
./audit_runner.sh all

# Step 2: Run detailed agent audit for a specific chapter
# (In OpenCode/Claude Code)
Task(
  description: "Detailed Chapter 10 Audit",
  prompt: "<from audit_skills.md - audit-chapter-10>",
  subagent_type: "explore"
)

# Step 3: Fix critical items
# Edit config/environments/production.rb to uncomment config.hosts
# Set OAuth credentials in Render dashboard
# Run bin/rails app:update for Rails 8.1 defaults

# Step 4: Re-run audit to verify fixes
./audit_runner.sh chapter10
./audit_runner.sh security
./audit_runner.sh pre-launch
```

---

## Integration with Codebase

The audit system is based on the **259 chapters** in `/Users/tichlabs/Documents/codebase/code/`:

- **ch01_00 to ch01_24** (25 steps) → Foundation checklist
- **ch02_01 to ch02_23** (23 steps) → Core Features checklist
- **ch03_01 to ch03_16** (16 steps) → Views & Styling checklist
- **ch04_01 to ch04_17** (17 steps) → Authentication checklist
- **ch05_01 to ch05_22** (22 steps) → Mobile PWA checklist
- **ch06_01 to ch06_32** (32 steps) → Advanced Features checklist
- **ch07_01 to ch07_23** (23 steps) → API Development checklist
- **ch08_00 to ch08_22** (23 steps) → Integration checklist
- **ch09_01 to ch09_09** (9 steps) → Testing checklist
- **ch10_01 to ch10_68** (68 steps) → Production checklist

---

## Next Steps

1. **Run the audit**: `./audit_runner.sh all`
2. **Review the output** and identify ⚠️/❌ items
3. **Fix critical (HIGH) items** first
4. **Re-run audit** to verify fixes
5. **Use agent skills** for deeper analysis of specific chapters
6. **Document progress** in `README.md` or `CHANGELOG.md`

---

## Files Reference

```
/Users/tichlabs/Documents/codebase/
├── guide.html              # Book-style HTML guide (with Audit System section)
├── GUIDE.md                # Markdown guide
├── dev-setup.html          # Dev environment setup
└── code/                  # 259 chapters (ch01_00 - ch10_68)

/Users/tichlabs/Documents/onlyCode/season/
├── audit_checklist.md      # Detailed checklist (all chapters)
├── audit_skills.md         # Agent skills (for Claude Code/OpenCode)
├── audit_runner.sh         # Bash audit script (executable)
├── README.md               # Season status & TODOs
├── CLAUDE.md               # AI agent instructions
└── AGENTS.md               # Agent commands & gotchas
```

---

**Created**: 2026-05-06
**Based on**: Codebase chapters (ch01_00 - ch10_68)
**For**: Season V2 - Women's cycle tracking PWA
