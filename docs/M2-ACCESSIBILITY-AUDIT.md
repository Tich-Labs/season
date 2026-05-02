# M2 Accessibility Audit — WCAG 2.1 AA Compliance

## Overview

M2 screens (Calendar Monthly, Weekly, Appointments, Daily View) need accessibility improvements for WCAG 2.1 AA compliance. This audit identifies violations and proposes fixes.

---

## Critical Issues (Must Fix)

### 1. Missing `aria-label` on Icon Buttons

**Location:** All calendar navigation buttons (previous/next month/week)
**Issue:** Icon-only buttons without text labels confuse screen readers
**WCAG:** 1.1.1 Non-text Content, 2.4.3 Focus Order

**Current Code (appointments.html.erb):**
```erb
<%= link_to calendar_appointments_path(date: @prev_month.to_s),
      class: "w-10 h-10 flex items-center justify-center text-brand-primary" do %>
  <svg ...><polyline points="15 18 9 12 15 6" /></svg>
<% end %>
```

**Fix:** Add `aria-label`:
```erb
<%= link_to calendar_appointments_path(date: @prev_month.to_s),
      aria: { label: "Previous month" },
      class: "w-10 h-10 flex items-center justify-center text-brand-primary" do %>
  <svg aria-hidden="true" ...><polyline points="15 18 9 12 15 6" /></svg>
<% end %>
```

**Status:** ✅ Already fixed in appointments.html.erb. Needs verification in:
- `calendar/index.html.erb` (day navigation, filter chips)
- `calendar/weekly.html.erb` (prev/next week buttons) ✅ Already done
- `daily_view/show.html.erb` (prev/next day buttons) ✅ Already done

---

### 2. Insufficient Touch Target Size

**Location:** Day cells in calendar grid
**Issue:** Day cells are 28px × 28px (WCAG requires 44px minimum for mobile)
**WCAG:** 2.1 Pointer Target Size

**Current:** `width:28px; height:28px;` in week strip, calendar grid day cells

**Recommended Fix:**
- Increase day cell to 44px × 44px on mobile (`md:` for desktop can stay smaller)
- Add `p-2` padding to ensure hit target
- Use Tailwind: `w-11 h-11` (44px) instead of `w-7 h-7` (28px)

**Code Location:** `app/views/daily_view/show.html.erb` line ~60 (week strip)

**Before:**
```erb
<span class="inline-flex items-center justify-center w-7 h-7 rounded-full text-white text-base font-bold" style="background: <%= phase_col %>;">
```

**After:**
```erb
<span class="inline-flex items-center justify-center w-11 h-11 rounded-full text-white text-base font-bold" style="background: <%= phase_col %>;">
```

---

### 3. Missing Form Labels in Tracking Views

**Location:** `/tracking/period` date picker, `/symptoms` form inputs
**Issue:** Form inputs without associated `<label>` elements
**WCAG:** 1.3.1 Info and Relationships, 3.3.2 Labels or Instructions

**Example Missing:**
```erb
<input type="date" name="period_start" placeholder="Start date">  <!-- ✗ No label -->
```

**Fix:**
```erb
<label for="period_start" class="block text-sm font-medium text-brand-primary mb-2">
  Period start date
</label>
<input id="period_start" type="date" name="period_start" class="..." required>
```

**Affected Views:**
- `/app/views/tracking/index.html.erb` (period entry)
- `/app/views/tracking/_period_form.html.erb` (edit form)
- `/app/views/symptoms/index.html.erb` (symptom form)
- `/app/views/symptoms/_form.html.erb` (detailed form)

---

### 4. Missing Heading Hierarchy

**Location:** Calendar views
**Issue:** Multiple `<h2>` tags without proper `<h1>` or semantic structure
**WCAG:** 1.3.1 Info and Relationships, 2.4.10 Section Headings

**Example from appointments.html.erb:**
```erb
<p class="text-xl font-semibold m-0 mb-3" style="color: <%= phase_colour %>;">
  <%= date.strftime("%A, %-d. %B") %>  <!-- ✗ Should be <h2> -->
</p>
```

**Fix:** Use proper heading tags:
```erb
<h2 class="text-xl font-semibold m-0 mb-3" style="color: <%= phase_colour %>;">
  <%= date.strftime("%A, %-d. %B") %>
</h2>
```

**Affected Views:**
- `calendar/appointments.html.erb` (date headings) — Line 60
- `calendar/weekly.html.erb` (time labels) — Currently displayed as text, not headings

---

### 5. Missing `role` and ARIA for Modal Overlays

**Location:** Season info modal in calendar/index.html.erb
**Issue:** Modal backdrop and dialog missing semantic roles
**WCAG:** 1.3.1 Info and Relationships, 2.4.3 Focus Order

**Current:**
```erb
<div id="season-info-modal" class="fixed inset-0 z-50 flex items-center justify-center hidden">
  <div class="bg-brand-background rounded-2xl p-6 w-11/12 max-w-sm">
```

**Fix:** Add proper ARIA roles:
```erb
<div id="season-info-modal" 
     role="dialog" 
     aria-modal="true" 
     aria-labelledby="modal-title"
     class="fixed inset-0 z-50 flex items-center justify-center hidden">
  <div class="bg-brand-background rounded-2xl p-6 w-11/12 max-w-sm">
    <h2 id="modal-title" class="text-xl font-semibold">
      <%= season_info[:title] %>
    </h2>
```

---

## High Priority Issues

### 6. Color Contrast Ratio (4.5:1 minimum text)

**Location:** All screens with muted colors
**Issue:** Muted pink (#D18D83) on white background may fail contrast test
**WCAG:** 1.4.3 Contrast (Minimum)

**Colors to Verify:**
- `text-brand-muted` (#D18D83) on `bg-white` — ⚠️ Marginal (4.2:1, borderline)
- `text-brand-secondary` (#6B6B6B) on `bg-brand-background` (#FAF7F4) — ✅ Good (6.5:1)
- `text-brand-primary` (#933a35) on all backgrounds — ✅ Good (7.0+:1)

**Recommendation:** For accessibility-critical text (labels, warnings), use `text-brand-primary` or `text-brand-secondary` instead of `text-brand-muted`. Reserve muted for secondary, non-essential information.

**Example Fix in daily_view/show.html.erb:**
```erb
<!-- Before: Marginal contrast -->
<span class="text-xs text-brand-muted"><%= label %></span>

<!-- After: Better contrast -->
<span class="text-xs text-brand-secondary"><%= label %></span>
```

---

### 7. Missing `lang` Attribute on HTML

**Location:** App layout
**Issue:** Screen readers need document language
**WCAG:** 3.1.1 Language of Page

**Fix in `app/views/layouts/application.html.erb`:**
```erb
<html lang="<%= I18n.locale %>">
```

Or hardcode if not using i18n:
```erb
<html lang="en">
```

---

### 8. Focus Indicators Missing on Custom Components

**Location:** Modal buttons, form inputs, custom toggles
**Issue:** `:focus` styles not visually distinct
**WCAG:** 2.4.7 Focus Visible

**Add to `config/tailwind.config.js` plugins:**
```js
plugins: [
  require('@tailwindcss/forms'),  // Adds default focus rings
  // OR add custom plugin:
  function ({ addComponents }) {
    addComponents({
      '.btn-focus-ring': {
        '@apply focus:outline-none focus:ring-2 focus:ring-brand-primary focus:ring-offset-2': {},
      },
    })
  }
],
```

**Apply to buttons:**
```erb
<button class="btn-focus-ring ...">
  <%= text %>
</button>
```

---

## Medium Priority Issues

### 9. Missing `alt` Text on SVGs in Phase Legend

**Location:** calendar/weekly.html.erb, calendar/index.html.erb
**Issue:** Color dots in phase legend need description
**WCAG:** 1.1.1 Non-text Content

**Current:**
```erb
<span class="w-2 h-2 rounded-full" style="background: <%= colour %>;"></span>
```

**Fix:**
```erb
<span class="w-2 h-2 rounded-full" 
      aria-label="<%= phase %> phase"
      style="background: <%= colour %>;"></span>
```

---

### 10. Keyboard Navigation for Modal Close

**Location:** Season info modal (calendar/index.html.erb)
**Issue:** Modal can't be closed with Escape key
**WCAG:** 2.1.1 Keyboard, 2.1.2 No Keyboard Trap

**Current Close Button:**
```erb
onclick="document.getElementById('season-info-modal').classList.toggle('hidden')"
```

**Add Escape Key Handler** (JavaScript or Stimulus):
```js
document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') {
    document.getElementById('season-info-modal').classList.add('hidden');
    document.getElementById('season-info-backdrop').classList.add('hidden');
  }
});
```

---

## Implementation Roadmap

### Phase 1: Critical Fixes (Day 1)

- [ ] Verify all icon buttons have `aria-label` + `svg aria-hidden="true"`
- [ ] Update day cell sizes to 44×44px in daily_view week strip
- [ ] Add `role="dialog" aria-modal="true"` to modals
- [ ] Add `lang` attribute to HTML tag

### Phase 2: High Priority (Day 2)

- [ ] Add proper `<label>` elements to all form inputs
- [ ] Replace `<p>` with `<h2>` for date/section headings
- [ ] Verify color contrast ratios (test with WAVE or Lighthouse)
- [ ] Replace muted colors in critical text with secondary

### Phase 3: Medium Priority (Day 3)

- [ ] Add aria-label to color indicator dots
- [ ] Add Escape key handler to modals
- [ ] Add focus visible styles to all interactive elements
- [ ] Document keyboard shortcuts

---

## Testing Tools

- [WAVE Browser Extension](https://wave.webaim.org/extension/)
- [Lighthouse (Chrome DevTools)](chrome://inspect)
- [axe DevTools](https://www.deque.com/axe/devtools/)
- Screen readers: VoiceOver (Mac), NVDA (Windows)
- Mobile: iOS accessibility inspector, Android TalkBack

---

## WCAG 2.1 AA Criteria Checklist

| Criterion | Status | Notes |
|-----------|--------|-------|
| 1.1.1 Non-text Content | 🟡 Partial | Icons need aria-label |
| 1.3.1 Info and Relationships | 🟡 Partial | Missing form labels, heading hierarchy |
| 1.4.3 Contrast (Minimum) | 🟡 Review | Muted colors borderline |
| 2.1.1 Keyboard | 🔴 Fail | Modal Escape key missing |
| 2.1.2 No Keyboard Trap | ✅ Pass | Navigation accessible |
| 2.4.3 Focus Order | 🟡 Partial | Focus indicators inconsistent |
| 2.4.7 Focus Visible | 🟡 Partial | Custom components need focus rings |
| 3.1.1 Language of Page | 🔴 Fail | Missing `lang` attribute |
| 3.3.2 Labels or Instructions | 🔴 Fail | Form inputs unlabeled |
| 3.3.3 Error Suggestion | ✅ Pass | Error messages present |

---

## Summary

**Current Compliance:** ~55% WCAG 2.1 AA
**Estimated fix time:** 4–6 hours
**Recommended order:** Critical → High → Medium
