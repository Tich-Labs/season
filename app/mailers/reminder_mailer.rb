class ReminderMailer < ApplicationMailer
  def morning_summary(user)
    @user = user
    @calculator = CycleCalculatorService.new(user)
    @phase = @calculator.current_phase || "follicular"
    @cycle_day = @calculator.current_cycle_day
    @season = @calculator.current_season || "Spring"
    @phase_meta = CycleCalculatorService::PHASE_META[@phase]

    mail(to: user.email, subject: "Good morning, #{user.name.split.first} 🌸 Your Season summary")
  end

  def period_reminder(user, event_type)
    @user = user
    @event_type = event_type
    @calculator = CycleCalculatorService.new(user)
    @predicted_date = predicted_period_date(user, event_type)

    subject = (event_type == "period_start") ? "Your period is starting soon 🌙" : "Your period is almost over 🌱"
    mail(to: user.email, subject: subject)
  end

  def birth_control_reminder(user)
    @user = user
    @contraception = user.contraception_type.presence || "none"
    @calculator = CycleCalculatorService.new(user)
    @cycle_day = @calculator.current_cycle_day

    mail(to: user.email, subject: t("reminder_mailer.birth_control_reminder.subject"))
  end

  private

  def predicted_period_date(user, event_type)
    return nil unless user.last_period_start && user.cycle_length
    last = user.last_period_start.to_date
    cycle = user.cycle_length || 28
    period_len = user.period_length || 5
    today = Time.zone.today
    next_start = last + cycle
    next_start += cycle while next_start <= today
    (event_type == "period_end") ? next_start + period_len - 1 : next_start
  end
end
