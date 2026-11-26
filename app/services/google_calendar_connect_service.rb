# frozen_string_literal: true

# Completes a Google Calendar OAuth handoff without depending on a browser
# redirect landing back in the Turbo Native WebView. Both the web callback and
# the native callback endpoint go through here so token exchange, persistence
# and import behave identically.
class GoogleCalendarConnectService
  Result = Data.define(:imported, :error) do
    def success? = error.nil?
  end

  def self.call(user:, code:, redirect_uri:, direction:) = new(user:, code:, redirect_uri:, direction:).call

  def initialize(user:, code:, redirect_uri:, direction:)
    @user = user
    @code = code
    @redirect_uri = redirect_uri
    @direction = direction.presence_in(User::CALENDAR_SYNC_DIRECTIONS) || "one_way"
  end

  def call
    client = build_client
    client.code = @code
    client.redirect_uri = @redirect_uri
    client.fetch_access_token!

    @user.update!(
      google_access_token: client.access_token,
      google_refresh_token: client.refresh_token.presence || @user.google_refresh_token,
      google_token_expires_at: client.expires_at ? Time.zone.at(client.expires_at) : nil,
      google_calendar_email: fetch_google_email(client.access_token),
      calendar_sync_level: @direction
    )
    enqueue_backfill if @direction == "two_way"

    Result.new(imported: GoogleCalendarImportService.call(user: @user), error: nil)
  rescue Signet::AuthorizationError => e
    Rails.logger.warn("[GoogleCalendar] token exchange rejected: #{e.message}")
    Result.new(imported: 0, error: e)
  rescue => e
    Rails.logger.error("[GoogleCalendar] connect failed for user #{@user.id}: #{e.class}: #{e.message}")
    Result.new(imported: 0, error: e)
  end

  private

  def build_client
    Signet::OAuth2::Client.new(
      client_id: ENV["GOOGLE_CLIENT_ID"],
      client_secret: ENV["GOOGLE_CLIENT_SECRET"],
      authorization_uri: "https://accounts.google.com/o/oauth2/v2/auth",
      token_credential_uri: "https://oauth2.googleapis.com/token"
    )
  end

  def fetch_google_email(access_token)
    uri = URI("https://www.googleapis.com/oauth2/v3/userinfo")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{access_token}"
    JSON.parse(http.request(request).body)["email"]
  rescue
    nil
  end

  def enqueue_backfill
    @user.calendar_events.from_season.where(google_event_id: nil).find_each do |event|
      GoogleCalendarPushJob.perform_later("create", user_id: @user.id, calendar_event_id: event.id)
    end
  end
end
