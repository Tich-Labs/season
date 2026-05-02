# M2 Pixel-Perfect Audit (Calendar with Basic Cycle & Display)
**Date**: 2 May 2026  
**Status**: Detailed Screen-by-Screen Analysis  
**Milestone**: M2 (32 screens, 70% current compliance)

---

## Executive Summary

M2 contains 5 unique view files with multiple inline style violations preventing pixel-perfect compliance. The calendar/index.html.erb has been partially converted in Tier 1, but 3 critical inline styling regions remain. Weekly and daily views still heavily use inline styles.

**Compliance by Screen:**
- ✅ 30-35%: Fully Tailwind + brand classes  
- 🟡 65-70%: Mixed (some Tailwind, lots of inline `style=""`)
- ❌ 0%: Pure inline styles (no conversion)

---

## Screen 1: Calendar Monthly (index.html.erb)

**Status**: 50% converted (Tier 1 partial)  
**Test**: PASSING (166/166)

### ✅ CONVERTED (Tier 1)
- Header: ✅ Tailwind classes applied
- Dropdown menu: ✅ Brand colors fixed (#f5ede8 → #EDE1D5)
- No-cycle banner: ✅ Tailwind (bg-brand-error, border-brand-primary)
- Greeting section: ✅ Tailwind with Montserrat font
- Streak display: ✅ Tailwind (flex, bg-white, rounded-lg)

### ❌ REMAINING INLINE STYLES (Filter chips, Calendar grid, Legend, Modal)

#### Issue 1: Filter chips (Active/Inactive states)
**Location**: Lines ~74-80  
**Current** (inline):
```erb
style="padding:5px 14px; border-radius:20px; font-size:12px; font-weight:600; text-decoration:none; background:#{active ? '#933a35' : '#FFFFFF'}; color:#{active ? '#FFFFFF' : '#933a35'}; border:1px solid #933a35;"
```
**Spec**: Active chip = `#933a35` bg + white text, inactive = white bg + `#933a35` text + border  
**Fix**: Convert to Tailwind with conditional classes
```erb
<%= link_to label,
      user_root_path(date: @date.to_s, mode: value),
      class: "px-3.5 py-1.5 rounded-full text-xs font-semibold no-underline " +
             (active ? "bg-brand-primary text-white" : "bg-white text-brand-primary border border-brand-primary") %>
```
**Impact**: Affects all filter interactions (All, Events, Tracked, Cycle)

#### Issue 2: Day-of-week headers
**Location**: Lines ~83-89  
**Current** (inline):
```erb
style="text-align:center; color:#6B6B6B; font-size:11px; font-weight:600; letter-spacing:0.04em; padding:4px 0;"
```
**Spec**: 11px, 600 weight, centered, letter-spacing, secondary color  
**Fix**: 
```erb
class="text-center text-brand-secondary text-xs font-semibold tracking-wider py-1"
```

#### Issue 3: Phase Legend (circular dots + labels)
**Location**: Lines ~94-111  
**Current** (inline): ~18 inline style attributes  
**Issues**:
- Legend dots use hardcoded hex (`background:#933a35` etc) instead of phase color classes
- Text color: `#6B6B6B` hardcoded instead of `text-brand-secondary`
- Spacing: pixel values (gap:12px, padding:4px) instead of Tailwind (gap-3, px-1)
- Button (info icon) has `background:none; border:none; cursor:pointer; padding:0 4px` instead of Tailwind

**Fix Pattern**:
```erb
<div class="flex gap-3 justify-center flex-wrap mb-3">
  <% [["menstrual", "#933a35"], ["follicular", "#D18D83"], ["ovulation", "#F5C6AD"], ["luteal", "#EDE1D5"]].each do |label, color| %>
    <div class="flex items-center gap-1">
      <span class="w-2.5 h-2.5 rounded-full" style="background: <%= color %>;"></span>
      <span class="text-xs text-brand-secondary capitalize"><%= label %></span>
    </div>
  <% end %>
  <button class="bg-none border-none cursor-pointer px-1" onclick="...">
    <svg class="w-4 h-4 text-brand-secondary">...</svg>
  </button>
</div>
```

#### Issue 4: Calendar grid styling
**Location**: Lines ~114-130  
**Current** (inline): Grid uses `display:grid; grid-template-columns:repeat(7,1fr); grid-auto-rows:85px; gap:8px 0;`  
**Spec**: 85px row height, 8px gap, 7 columns  
**Fix**: 
```erb
<div class="grid grid-cols-7 auto-rows-[85px] gap-x-0 gap-y-2">
```
**Note**: Tailwind doesn't support arbitrary grid-auto-rows directly, so may need:
```scss
.calendar-grid {
  @apply grid grid-cols-7 gap-y-2;
  grid-auto-rows: 85px;
}
```

#### Issue 5: Season Info Modal (overlay)
**Location**: Lines ~140-185  
**Current** (inline): 26 style attributes  
**Issues**:
- Position: `position:fixed; inset:0; background:rgba(0,0,0,0.5); z-index:100; align-items:center; justify-content:center;`
- Container: `border-radius:16px; padding:24px; width:90%; max-width:340px; margin:16px;`
- All text colors hardcoded: `color:#933a35`, `color:#D18D83`
- Button: `width:100%; background:#933a35; color:white; border:none; border-radius:12px; padding:14px; font-size:16px; font-weight:500; cursor:pointer;`

**Fix**: Use modal_backdrop component (already created in Tier 1) + Tailwind
```erb
<div id="season-info-modal" class="hidden fixed inset-0 bg-black bg-opacity-70 z-50 flex items-center justify-center">
  <div class="bg-brand-background rounded-2xl p-6 w-11/12 max-w-sm">
    <div class="text-center mb-4">
      <div class="w-15 h-15 rounded-full bg-brand-primary inline-flex items-center justify-center text-4xl mb-3">
        <%= season_info[:emoji] %>
      </div>
      <h3 class="text-brand-primary text-xl font-semibold m-0">
        <%= season_info[:title] %>
      </h3>
      <p class="text-brand-muted text-sm m-1 mt-0">
        You're in <%= season_info[:title].downcase %> phase
      </p>
    </div>
    
    <p class="text-brand-primary text-sm leading-relaxed mb-4 text-center">
      <%= season_info[:description] %>
    </p>
    
    <div class="bg-white rounded-lg p-3 mb-4">
      <p class="text-brand-primary text-xs font-semibold mb-2 m-0">Tips for this phase</p>
      <ul class="m-0 pl-4">
        <% season_info[:tips].each do |tip| %>
          <li class="text-brand-secondary text-sm mb-1"><%= tip %></li>
        <% end %>
      </ul>
    </div>
    
    <button class="w-full bg-brand-primary text-white rounded-lg py-3.5 text-base font-medium cursor-pointer"
            onclick="document.getElementById('season-info-modal').classList.add('hidden')">
      Got it
    </button>
  </div>
</div>
```

**Severity**: HIGH - Modal is secondary, but affects UX consistency

---

## Screen 2: Calendar Weekly (weekly.html.erb)

**Status**: 5% converted  
**Issues Found**: 34 inline style violations

### Critical Inline Styles

#### Issue 1: Week header navigation
**Location**: Lines ~8-16  
**Current**: `class: "w-10 h-10 flex items-center justify-center text-[#933a35]"` + mixed styles  
**Problem**: Uses arbitrary value `text-[#933a35]` instead of `text-brand-primary`  
**Fix**: Apply `text-brand-primary` class instead

#### Issue 2: Week header dates
**Location**: Line ~14  
**Current**: `style="text-align:center; color:#6B6B6B; font-size:11px; font-weight:600; letter-spacing:0.04em; padding:4px 0;"`  
**Fix**: Convert to Tailwind class

#### Issue 3: Day columns (7-column grid)
**Location**: Lines ~37-43  
**Current**:
```erb
style="display:grid; grid-template-columns:repeat(7,1fr); gap:0; padding:12px 8px 8px; border-bottom:1px solid #EDE1D5; background:#FFFFFF;"
```
**Fix**:
```erb
class="grid grid-cols-7 gap-0 py-3 px-2 border-b border-brand-field bg-white"
```

#### Issue 4: Timeline grid (hours + events)
**Location**: Lines ~58-75  
**Current**: 12+ inline style attributes per row  
**Problems**:
- `border-right:1px solid #EDE1D5;` - hardcoded color
- `height:48px` - pixel value instead of Tailwind (h-12 = 48px)
- Hardcoded `#6B6B6B` and `#F5EDE8` colors
- Hardcoded `font-size:10px` and padding values

**Fix**: Use helper classes + Tailwind
```erb
<div class="grid gap-0" style="grid-template-columns: 40px 1fr;">
  <div class="border-r border-brand-field">
    <% timeline_hours.each do |hour| %>
      <div class="h-12 border-b border-[#F5EDE8]">
        <span class="text-xs text-brand-secondary p-0.5 block">
          <%= format("%02d:00", hour) %>
        </span>
      </div>
    <% end %>
  </div>
  ...
</div>
```

**Severity**: CRITICAL - Timeline is 60% of screen, ~20 inline style violations

---

## Screen 3: Calendar Appointments (appointments.html.erb)

**Status**: Not fully reviewed yet  
**Estimated Issues**: 15-20 inline styles

**Quick scan needed for**:
- Appointment cards (background, padding, border-radius)
- Appointment list headers
- Empty state messaging
- Color usage for event types

---

## Screen 4: Daily View (daily_view/show.html.erb)

**Status**: Not fully reviewed yet  
**Estimated Issues**: 25-30 inline styles

**Quick scan needed for**:
- Date selector
- Time grid background colors
- Event cards within timeline
- Phase color bands
- Current time indicator styling

---

## Screen 5: Day Cell Component (_day_cell.html.erb)

**Status**: Not reviewed  
**Component Purpose**: Renders individual day cells in calendar grid  
**Estimated Issues**: 10-15 inline styles

---

## Consolidated Fix Priority

### TIER 2a (2-3 hours): Calendar Monthly Completion
1. ✅ Filter chips → Tailwind (conditional classes)
2. ✅ Day headers → Tailwind (text-xs, tracking)
3. ✅ Phase legend → Tailwind + phase color classes
4. ✅ Calendar grid → Tailwind grid utilities
5. ✅ Season info modal → Tailwind + modal_backdrop component

### TIER 2b (2-3 hours): Weekly View
1. ✅ Navigation arrows → Fix text-[#933a35] to text-brand-primary
2. ✅ Week header grid → Tailwind (grid-cols-7)
3. ✅ Timeline columns → Tailwind borders + colors
4. ✅ Timeline hours → Tailwind (text-xs, text-brand-secondary)
5. ✅ Event positioning → Audit overflow + z-index

### TIER 2c (1-2 hours): Appointments + Daily
1. ✅ Quick audit for inline styles
2. ✅ Card styling conversion
3. ✅ Color standardization

---

## Color References (for verification)

| Color | Hex | Usage | Status |
|-------|-----|-------|--------|
| Primary | #933a35 | Buttons, text, active states | ✅ Branded |
| Secondary | #6B6B6B | Labels, muted text | ✅ Branded |
| Background | #FAF7F4 | Page background | ✅ Branded |
| Field bg | #EDE1D5 | Form fields, hover states | ✅ Branded |
| Menstrual | #933a35 | Phase color (same as primary) | ⚠️ Check |
| Follicular | #D18D83 | Phase color | ✅ Branded |
| Ovulation | #F5C6AD | Phase color | ✅ Branded |
| Luteal | #EDE1D5 | Phase color (same as field) | ⚠️ Check |
| Error bg | #FDF0EE | Error containers | ✅ Branded |
| Muted | #D18D83 | Secondary labels | ✅ Branded |

**⚠️ Watch out**: Menstrual (primary) and Luteal (field bg) can be visually confusing.

---

## Test Coverage

All changes should maintain:
- ✅ 166+ tests passing
- ✅ ERB lint clean
- ✅ Responsive (430px max-width)
- ✅ Touch targets (44px minimum)
- ✅ Color contrast (WCAG AA)

---

## Implementation Commands

```bash
# Run tests after each Tier 2 section
bin/rails test

# Lint ERB files
bundle exec erb_lint app/views/calendar/*.html.erb app/views/daily_view/*.html.erb

# Dev server
bin/dev
```

---

## Next Steps

1. **Start Tier 2a**: Convert calendar/index.html.erb remaining 5 issues
2. **Verify**: Screenshot against Figma (using browser comparison)
3. **Move to 2b**: Weekly view conversion
4. **Move to 2c**: Appointments + daily views
5. **M7 Audit**: Start Onboarding & Feedback milestone

---

**Estimated Time**: Tier 2a (2h) + 2b (2.5h) + 2c (1.5h) = **6 hours** for full M2 pixel-perfect compliance
