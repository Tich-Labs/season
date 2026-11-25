class GoogleCalendarImportService
  def self.call(user:) = new(user:).call

  def initialize(user:)
    @user = user
  end

  def call
    events = GoogleCalendarService.new(@user).list_events(
      time_min: 3.months.ago.iso8601,
      time_max: 3.months.from_now.iso8601,
      max_results: 250
    )

    Array(events).sum { |event| import(event) }
  end

  private

  def import(event)
    start_time = event.start&.date_time || event.start&.date&.to_time
    return 0 unless start_time
    return 0 if @user.calendar_events.exists?(google_event_id: event.id)

    end_time = event.end&.date_time || event.end&.date&.to_time
    @user.calendar_events.create!(
      google_event_id: event.id,
      source: "google",
      title: event.summary.presence || I18n.t("calendar.appointments.untitled"),
      date: start_time.to_date,
      start_time: start_time.strftime("%H:%M"),
      end_time: end_time&.strftime("%H:%M")
    )
    1
  end
end
