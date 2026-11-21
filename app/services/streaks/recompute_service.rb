# frozen_string_literal: true

# Rebuilds the streak from the user's actual tracking dates instead of relying
# on the last increment alone. Backfilling yesterday (or any past day) must
# contribute to the flame count; otherwise a user who fills in several days in
# one sitting stays stuck at 1.
class Streaks::RecomputeService
  def self.call(user:) = new(user:).call

  def initialize(user:)
    @user = user
  end

  def call
    dates = tracked_dates
    return if dates.empty?

    streak = @user.streak || @user.create_streak!(current_streak: 0, longest_streak: 0, total_flames: 0)
    computed = compute(dates)
    return streak if regression?(streak, computed)

    streak.update!(
      current_streak: computed[:current],
      longest_streak: [streak.longest_streak.to_i, computed[:longest]].max,
      total_flames: [streak.total_flames.to_i, computed[:flames]].max,
      last_tracked_date: computed[:last_date],
      grace_week: computed[:grace_week],
      grace_used: computed[:grace_used]
    )
    streak
  end

  private

  def tracked_dates
    [
      @user.symptom_logs.pluck(:date),
      @user.superpower_logs.pluck(:date),
      @user.period_starts.pluck(:started_on)
    ].flatten.compact.uniq.sort
  end

  def compute(dates)
    current = 0
    longest = 0
    flames = 0
    previous = nil
    grace_by_week = Hash.new(0)

    dates.each do |date|
      if previous.nil?
        current = 1
      else
        plan = Hash.new(0)
        survivable = true

        ((previous + 1.day)...date).each do |missed|
          next if rest_day?(missed)

          week = missed.beginning_of_week(:monday)
          if grace_by_week[week] + plan[week] >= Streak::GRACE_PER_WEEK
            survivable = false
            break
          end
          plan[week] += 1
        end

        if survivable
          plan.each { |week, used| grace_by_week[week] += used }
          current += 1
        else
          current = 1
          grace_by_week = Hash.new(0)
        end
      end

      longest = [longest, current].max
      flames += 1
      previous = date
    end

    grace_week = grace_by_week.keys.max
    {
      current: current,
      longest: longest,
      flames: flames,
      last_date: previous,
      grace_week: grace_week,
      grace_used: grace_week ? grace_by_week.fetch(grace_week) : 0
    }
  end

  def rest_day?(day)
    @user.respond_to?(:menstruating_on?) && @user.menstruating_on?(day)
  end

  # An old backfill must never shorten a streak that is already further along.
  def regression?(streak, computed)
    last = streak.last_tracked_date
    return false if last.nil?
    return true if computed[:last_date] < last

    computed[:last_date] == last && computed[:current] <= streak.current_streak.to_i
  end
end
