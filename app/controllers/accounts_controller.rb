class AccountsController < ApplicationController
  def show
  end

  def export
    user = current_user
    data = {
      profile: {
        name: user.name,
        email: user.email,
        birthday: user.birthday,
        language: user.language,
        created_at: user.created_at
      },
      cycle: {
        cycle_length: user.cycle_length,
        period_length: user.period_length,
        last_period_start: user.last_period_start,
        last_period_end: user.last_period_end,
        has_regular_cycle: user.has_regular_cycle,
        uses_hormonal_birth_control: user.uses_hormonal_birth_control,
        contraception_type: user.contraception_type,
        food_preference: user.food_preference
      },
      symptom_logs: user.symptom_logs.order(:date).map do |s|
        {date: s.date, mood: s.mood, energy: s.energy, pain: s.pain, notes: s.notes, temperature: s.temperature, weight: s.weight}
      end,
      calendar_events: user.calendar_events.order(:date).map do |e|
        {title: e.title, date: e.date, end_date: e.end_date, notes: e.notes}
      end
    }

    send_data data.to_json,
      filename: "season-export-#{Time.zone.today}.json",
      type: "application/json",
      disposition: "attachment"
  end

  def destroy
    user = current_user
    terminate_session
    user.destroy!
    redirect_to root_path, notice: t(".success")
  end
end
