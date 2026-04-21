# Styling Audit & Standardization Status

**Last Updated:** 2026-04-16

## ✅ COMPLETED

### Tailwind Configuration
- Added brand colors to `config/tailwind.config.js`:
  - `bg-brand-primary` / `text-brand-primary` → #933a35
  - `bg-brand-secondary` / `text-brand-secondary` → #6B6B6B
  - `bg-brand-background` → #FAF7F4
  - `bg-brand-field` → #EDE1D5
  - `bg-brand-error` → #FDF0EE
  - `text-brand-muted` → #D18D83
  - `text-brand-dark` → #3d2b28
- Added phase colors: `bg-phase-menstrual`, `bg-phase-follicular`, etc.
- Added `max-w-app` = 430px

### Views Converted to Tailwind
- Calendar/index.html.erb (partial)
- Tracking/index.html.erb (partial)
- Symptoms/index.html.erb (partial)
- Settings views (most)

---

## 🔶 IN PROGRESS

### Remaining Work
~50 view files still have inline `style=""` attributes that need conversion to Tailwind classes.

### Priority Order
1. Main app views (calendar, tracking, symptoms, superpowers, streaks)
2. Settings views
3. Auth views (sessions, registrations, passwords, onboarding)
4. Other views

---

## Styling Standard (REQUIRED)

**All new code and edits MUST use Tailwind classes - no inline `style=""` attributes.**

### Standard Patterns
```erb
<!-- Page wrapper -->
<div class="bg-brand-background min-h-screen pb-20">
  <div class="max-w-app mx-auto px-4">

<!-- Card -->
<div class="bg-white rounded-2xl p-5">

<!-- Section header -->
<h2 class="text-lg font-bold text-brand-dark mb-4">

<!-- Form field -->
<input class="w-full bg-brand-field rounded-xl px-4 py-3 text-brand-dark">

<!-- Primary button -->
<button class="w-full bg-brand-primary text-white rounded-xl py-3.5 font-semibold">
```

### When inline styles ARE allowed
- Dynamic phase colors from `CycleCalculatorService::PHASE_META`
- Complex calculations (SVG paths, animations)

Example:
```erb
<div class="rounded-xl p-4" style="background:<%= phase_colour %>;">
```

### What NOT to do
- No `style="color:#933a35"` → use `text-brand-primary`
- No `style="background:#FAF7F4"` → use `bg-brand-background`
- No hardcoded hex colors in classes → use brand classes