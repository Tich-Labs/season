class GoogleCalendarService
  SCOPES = ["https://www.googleapis.com/auth/calendar"].freeze

  def initialize(user)
    @user = user
  end

  def list_events(max_results: 20, time_min: nil, time_max: nil)
    return [] unless @user.google_calendar_connected?

    service = build_service
    time_min ||= Time.zone.now.iso8601
    response = service.list_events(
      "primary",
      max_results: max_results,
      single_events: true,
      order_by: "startTime",
      time_min: time_min,
      time_max: time_max
    )
    response.items
  rescue Google::Apis::AuthorizationError
    nil
  end

  def create_event(summary:, start_time:, end_time:, description: nil, location: nil)
    return nil unless @user.google_calendar_connected?

    service = build_service
    event = Google::Apis::CalendarV3::Event.new(
      summary: summary,
      description: description,
      location: location,
      start: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: start_time,
        time_zone: Time.zone.name
      ),
      end: Google::Apis::CalendarV3::EventDateTime.new(
        date_time: end_time,
        time_zone: Time.zone.name
      )
    )
    service.insert_event("primary", event)
  rescue Google::Apis::AuthorizationError
    nil
  end

  def delete_event(event_id)
    return false unless @user.google_calendar_connected?

    service = build_service
    service.delete_event("primary", event_id)
    true
  rescue Google::Apis::AuthorizationError
    false
  end

  private

  def build_service
    @user.refresh_google_token_if_needed!
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = "Season"
    service.authorization = auth_client
    service
  end

  def auth_client
    Signet::OAuth2::Client.new(
      client_id: ENV["GOOGLE_CLIENT_ID"],
      client_secret: ENV["GOOGLE_CLIENT_SECRET"],
      token_credential_uri: "https://oauth2.googleapis.com/token",
      access_token: @user.google_access_token,
      refresh_token: @user.google_refresh_token,
      expires_at: @user.google_token_expires_at&.to_i
    )
  end
end
