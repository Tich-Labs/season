class ReminderMailer < ApplicationMailer
  def morning_summary(user)
    @user = user
    @calculator = CycleCalculatorService.new(user)
    @phase = @calculator.current_phase || "follicular"
    @cycle_day = @calculator.current_cycle_day
    @season = @calculator.current_season || "Spring"
    @phase_meta = CycleCalculatorService::PHASE_META[@phase]

    mail(to: user.email, subject: t(".subject", name: user.name.split.first))
  end

  def period_reminder(user, event_type)
    @user = user
    @event_type = event_type
    next_start = CycleCalculatorService.new(user).next_period_start
    @predicted_date = (event_type == "period_end" && next_start) ? next_start + (user.period_length || 5) - 1 : next_start

    mail(to: user.email, subject: t(".subject_#{event_type}"))
  end

  def birth_control_reminder(user)
    @user = user
    @contraception = user.contraception_type.presence || "none"
    @calculator = CycleCalculatorService.new(user)
    @cycle_day = @calculator.current_cycle_day

    mail(to: user.email, subject: t(".subject"))
  end
end
