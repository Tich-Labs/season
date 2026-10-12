# Streak Counter

The streak counts **tracking days** — a day on which the user recorded any
symptom, superpower, or period info. It is a motivation feature, so it was
redesigned around two ideas: **quick wins** (more ways to count) and
**forgiveness** (missing one day shouldn't erase months of effort).

## What counts (quick wins)

Any of these advances today's streak (once — see idempotency):

- Submitting symptoms via `/symptoms` (mood, cravings, discharge, notes…)
  → `SymptomsController#create`
- A one-tap quick action on the symptoms page: physical symptom, mental
  symptom, bleeding flow
  → `SymptomsController#log_physical` / `log_mental` / `log_bleeding`
- Submitting superpowers → `SuperpowersController#create`
- Marking "period started" today → `TrackingController#create`
- Updating the period dates where the start date is today
  → `TrackingController#period_update`

### Backdated entries never count

Filling in a past day (via the date drum) is a "backfill", **not** a tracking
day. `Streakable#update_streak!` only calls the model when the saved entry's
date is today, so backdating log doesn't advance (or reset) today's streak.
Adding yesterday's data after the fact also can't rescue a broken streak —
the streak already reflects whether the user came back.

## The algorithm

`Streak#increment_streak!(on:)` runs on a write:

- If the last tracked date is the same as `on` → no-op (idempotent).
  Logging symptoms *and* superpowers in one day still counts once.
- Never tracked → streak becomes 1.
- Last tracked yesterday (no gap) → streak grows by 1.
- Gap of ≥1 missed day → check forgiveness (below). Survivable → streak grows
  by 1; otherwise → streak resets to 1.

`longest_streak = max(longest_streak, current_streak)` and
`total_flames += 1` whenever a tracking day is actually recorded.

## Forgiveness

A gap (missed days between the last track and today) is forgiven when **every**
missed day is either a rest day or covered by grace:

- **Rest days** — missed days inside a tracked period
  (`User#menstruating_on?`): start date through start date + `period_length`
  (default 5). Forgiven for free, never spend grace.
- **Grace** — at most **one** non-rest missed day per calendar week
  (Monday–Sunday), `Streak::GRACE_PER_WEEK`. Grace is stored per week on the
  streak row: `grace_week` (the Monday of the week it was spent) and
  `grace_used` (how many were spent that week). The budget resets each Monday.

So: skip one non-period day → streak survives. Skip two days in the same week
→ streak resets. Skip days across a week boundary, one per week → both
survive.

The forgiveness check is **pure** — `grace_plan(missed)` computes a plan
without persisting; `apply_grace(plan)` only writes `grace_week` / `grace_used`
for the most recent week, older weeks are irrelevant to future gaps.

## Reading the streak: display vs. stored

The stored `current_streak` is only updated when the user tracks something.
To avoid showing a stale number (e.g. "12 days" three days after they stopped),
display code calls **`current_value`**, which returns the stored count while
every day since the last track is still forgivable, and **0** otherwise.
`current_value` never mutates the row.

Read sites:

- `StreaksController#index` → `@current_streak` (also drives milestone unlock
  and "X more days" copy)
- `CalendarController#index` → `@streak` badge
- `TrackingController#index` → `@streak` (currently unused by the view)

Admin pages keep showing the raw stored `current_streak` (historical value).

## Schema

```
streaks
  current_streak    integer DEFAULT 0
  longest_streak    integer DEFAULT 0
  total_flames      integer DEFAULT 0
  last_tracked_date date
  grace_week        date          -- Monday of week the last grace was spent
  grace_used        integer DEFAULT 0
```

## Tests

- `test/models/streak_test.rb` — algorithm, forgiveness (grace + rest days +
  week resets), `current_value`, out-of-order guard.
- `test/controllers/{symptoms,superpowers,tracking}_controller_test.rb` —
  each counting endpoint advance the streak; backdated logs do not.