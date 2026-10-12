class Streak < ApplicationRecord
  belongs_to :user
  validates :user_id, uniqueness: true

  MILESTONES = [30, 50, 75, 100, 125].freeze

  # Forgiveness budget: at most one *non-rest* missed day may be forgiven per
  # calendar week (Monday–Sunday). Missed days that fall inside a tracked
  # period are "rest days" and are always forgiven, without spending grace.
  GRACE_PER_WEEK = 1

  # Register a tracking action for `on` (a calendar date, defaults to today).
  #
  # Callers should pass Time.zone.today — see Streakable#update_streak!, which
  # refuses backdated saves so filling in a past day never advances today's
  # streak. Idempotent: a second call on the same date is a no-op, so logging
  # symptoms *and* superpowers in one day only counts once.
  def increment_streak!(on: Time.zone.today)
    on = on.to_date
    return if last_tracked_date == on
    # Out-of-order/backdated writes are ignored rather than allowed to rewind
    # last_tracked_date.
    return if last_tracked_date && on < last_tracked_date

    if last_tracked_date.nil?
      self.current_streak = 1
    else
      missed = missed_days(last_tracked_date, on)
      survivable, plan = grace_plan(missed)
      if survivable
        apply_grace(plan)
        self.current_streak = current_streak.to_i + 1
      else
        # A gap we can't forgive: the streak starts over at 1.
        self.current_streak = 1
      end
    end

    self.longest_streak = [longest_streak.to_i, current_streak.to_i].max
    self.total_flames = total_flames.to_i + 1
    self.last_tracked_date = on
    save!
  end

  # Effective streak for *display*. Returns the stored number while the streak
  # is still alive (tracked today/yesterday, or every day since was forgiven),
  # otherwise 0. Reading never mutates, so a broken streak is shown accurately
  # before the user's next log — the stored current_streak stays stale until
  # then.
  def current_value(on: Time.zone.today)
    on = on.to_date
    return 0 if last_tracked_date.nil?
    return 0 if last_tracked_date > on
    return current_streak.to_i if last_tracked_date == on

    survivable, = grace_plan(missed_days(last_tracked_date, on))
    survivable ? current_streak.to_i : 0
  end

  def next_milestone
    MILESTONES.find { |m| m > current_streak.to_i }
  end

  def milestone_reached?
    MILESTONES.include?(current_streak.to_i)
  end

  private

  def missed_days(from, to)
    ((from + 1.day)..(to - 1.day)).to_a
  end

  # Can every missed day be forgiven? Returns [survivable?, plan], where plan
  # maps a week-start to the number of grace days that *would* be spent that
  # week. Pure — no state is written here.
  def grace_plan(missed)
    plan = Hash.new(0)
    missed.each do |day|
      next if rest_day?(day)
      week = week_start(day)
      return [false, plan] if stored_grace_for(week) + plan[week] >= GRACE_PER_WEEK
      plan[week] += 1
    end
    [true, plan]
  end

  # Persist the most recent week's grace usage (older weeks are irrelevant —
  # future gaps can only fall in the current or a later week).
  def apply_grace(plan)
    week = plan.keys.max
    return if week.nil?
    self.grace_week = week
    self.grace_used = plan.fetch(week)
  end

  def stored_grace_for(week)
    (grace_week == week) ? grace_used.to_i : 0
  end

  # A missed day inside a tracked period is a rest day: forgiven for free.
  def rest_day?(day)
    user.respond_to?(:menstruating_on?) && user.menstruating_on?(day)
  end

  def week_start(day)
    day.beginning_of_week(:monday)
  end
end
