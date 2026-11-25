require "test_helper"

# M1 + M5 — Settings screens
class SettingsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    sign_in_as(@alice)
    # AvatarService is a plain Ruby service, not ActiveRecord — the
    # RedundantActiveRecordAllMethod cop doesn't apply to its `.all`.
    @avatar_preset = AvatarService.all.first[:id] # rubocop:disable Rails/RedundantActiveRecordAllMethod
  end

  test "GET /settings/edit returns 200" do
    get edit_settings_path
    assert_response :success
  end

  # Removed — not in Figma. Access code lives only on My Profile now, which
  # is /settings/pin's sole entry point, so its hardcoded back link is correct.
  # My Subscriptions and Notifications & Reminders are coming soon: greyed out,
  # with a Coming soon pill and no links into their pages.
  test "GET /settings/edit locks My Subscriptions and Notifications & Reminders" do
    get edit_settings_path
    assert_response :success
    assert_no_match(%r{href="/settings/subscriptions"}, response.body)
    assert_no_match(%r{href="/settings/notifications"}, response.body)
    assert_match(/opacity-40 pointer-events-none/, response.body)
    assert_includes response.body, ERB::Util.html_escape(I18n.t("settings.edit.notifications_and_reminder"))
  end

  test "GET /settings/edit has no App Lock row" do
    get edit_settings_path
    assert_no_match(/App Lock/, response.body)
    assert_no_match(%r{href="/settings/pin"}, response.body)
  end

  test "GET /settings/consent returns 200 and its back link goes to the settings menu" do
    get "/settings/consent"
    assert_response :success
    # Its only real entry point is /settings/edit — the back link used to be
    # hardcoded to user_root_path (calendar), skipping past the settings menu
    # entirely instead of returning to where the user actually came from.
    assert_match %r{href="/settings/edit"}, response.body
  end

  test "GET /settings/profile returns 200" do
    get profile_settings_path
    assert_response :success
  end

  # /settings/profile has two real entry points — the main settings menu and
  # the avatar on /tracking — so its back link must reflect the actual
  # referer instead of assuming one fixed parent.
  test "GET /settings/profile back link reflects the settings menu as referer" do
    get profile_settings_path, headers: {"HTTP_REFERER" => edit_settings_url}
    assert_match %r{href="/settings/edit"}, response.body
  end

  test "GET /settings/profile back link reflects tracking as referer" do
    get profile_settings_path, headers: {"HTTP_REFERER" => tracking_index_url}
    assert_match %r{href="/tracking"}, response.body
  end

  test "GET /settings/profile back link falls back to settings menu with no referer" do
    get profile_settings_path
    assert_match %r{href="/settings/edit"}, response.body
  end

  test "GET /settings/profile back link ignores an off-site referer" do
    get profile_settings_path, headers: {"HTTP_REFERER" => "https://evil.example.com/phishing"}
    assert_match %r{href="/settings/edit"}, response.body
    assert_no_match(/evil\.example\.com/, response.body)
  end

  # Regression for a real reported bug: this used to trust *any* same-origin
  # referer. /account's back link also resolves dynamically from its own
  # referer, so leaving /account back to here made /account the referer for
  # this load -- pointing this page's back link at /account and ping-ponging
  # the two pages forever. /account isn't one of this page's two real entry
  # points (settings menu, or the avatar on /tracking), so it must be
  # ignored even though it's same-origin.
  test "GET /settings/profile back link ignores /account as an untrusted referer" do
    get profile_settings_path, headers: {"HTTP_REFERER" => account_url}
    # This page also has its own unrelated "Delete Account" row linking to
    # /account, so check the header's back link specifically, not just
    # absence of "/account" anywhere on the page.
    assert_select "header a[href='/settings/edit']"
    assert_select "header a[href='/account']", false
  end

  # Good morning set, period reminder and birth control reminder are not live
  # yet: greyed out with "Coming soon" and no links into their sub-pages.
  test "GET /settings/notifications locks morning, period and birth control reminders" do
    get notifications_settings_path
    assert_response :success
    assert_no_match(%r{href="/settings/notification_morning"}, response.body)
    assert_no_match(%r{href="/settings/notification_period"}, response.body)
    assert_no_match(%r{href="/settings/notification_birth_control"}, response.body)
    assert_operator response.body.scan("Coming soon").size, :>=, 4
  end

  test "GET /settings/notifications returns 200" do
    get notifications_settings_path
    assert_response :success
  end

  test "GET /settings/notification_morning returns 200" do
    get notification_morning_settings_path
    assert_response :success
  end

  test "GET /settings/notification_period returns 200" do
    get notification_period_settings_path
    assert_response :success
  end

  test "GET /settings/notification_birth_control returns 200" do
    get notification_birth_control_settings_path
    assert_response :success
  end

  test "GET /settings/subscriptions returns 200" do
    get subscriptions_settings_path
    assert_response :success
  end

  test "GET /settings/calendar returns 200" do
    get calendar_settings_path
    assert_response :success
  end

  test "GET /settings/calendar orders Google, Apple iCloud, then Microsoft Outlook" do
    get calendar_settings_path
    assert_response :success

    labels = [
      I18n.t("settings.calendar.google_calendar"),
      I18n.t("settings.calendar.icloud_sync"),
      I18n.t("settings.calendar.microsoft_sync")
    ]
    positions = labels.map { |label| response.body.index(ERB::Util.html_escape(label)) }

    assert positions.all?
    assert_equal positions, positions.sort
  end

  test "GET /settings/calendar keeps the iCloud connect form outside the preferences form" do
    get calendar_settings_path
    assert_response :success

    doc = Nokogiri::HTML(response.body)

    assert doc.at_css('form[action="/settings/connect_icloud_calendar"]')
    assert_empty doc.css("form form")
  end

  test "GET /settings/calendar keeps Google sync forms outside the preferences form" do
    @alice.update!(google_access_token: "access", google_refresh_token: "refresh",
      google_calendar_email: "user@gmail.com", calendar_sync_level: "one_way")

    get calendar_settings_path

    doc = Nokogiri::HTML(response.body)

    assert doc.at_css('form[action="/settings/disconnect_google_calendar"]')
    assert doc.at_css('form[action="/settings/sync_google_calendar"]')
    assert_empty doc.css("form form")
  end

  test "GET /settings/calendar does not invite password manager autofill on iCloud fields" do
    get calendar_settings_path
    assert_response :success

    doc = Nokogiri::HTML(response.body)
    email = doc.at_css('input[name="icloud_email"]')
    password = doc.at_css('input[name="icloud_app_password"]')

    assert_equal "off", email["autocomplete"]
    assert_equal "new-password", password["autocomplete"]
    assert_equal "true", email["data-lpignore"]
    assert_equal "true", password["data-1p-ignore"]
  end

  test "GET /settings/calendar shows sync direction options when Google is connected" do
    @alice.update!(google_access_token: "access", google_refresh_token: "refresh",
      google_calendar_email: "user@gmail.com", calendar_sync_level: "two_way")

    get calendar_settings_path

    assert_response :success
    assert_includes response.body, ERB::Util.html_escape(I18n.t("settings.calendar.sync_direction"))
    assert_includes response.body, ERB::Util.html_escape(I18n.t("settings.calendar.two_way_sync"))
    assert_includes response.body, "user@gmail.com"
    assert_match(/data-calendar-sync-direction-target="option"/, response.body)
  end

  test "GET /settings/calendar renders the choose-direction sheet for Connect" do
    get calendar_settings_path

    assert_response :success
    assert_includes response.body, ERB::Util.html_escape(I18n.t("settings.calendar.sync_sheet_title"))
    assert_includes response.body, ERB::Util.html_escape(I18n.t("settings.calendar.connect_with_google"))
    assert_match(/data-action="click->calendar-sync-sheet#open"/, response.body)
  end

  test "PATCH /settings/update_google_calendar_sync persists the chosen direction" do
    @alice.update!(google_access_token: "access", google_refresh_token: "refresh", calendar_sync_level: "two_way")

    patch update_google_calendar_sync_settings_path, params: {direction: "one_way"}

    assert_response :success
    assert_equal "one_way", @alice.reload.calendar_sync_level
  end

  test "PATCH /settings/update_google_calendar_sync pushes existing events when switching to two-way" do
    @alice.update!(google_access_token: "access", google_refresh_token: "refresh", calendar_sync_level: "one_way")
    event = @alice.calendar_events.create!(title: "Dentist", date: Date.current)

    assert_enqueued_with(job: GoogleCalendarPushJob, args: ["create", {user_id: @alice.id, calendar_event_id: event.id}]) do
      patch update_google_calendar_sync_settings_path, params: {direction: "two_way"}
    end
    assert_equal "two_way", @alice.reload.calendar_sync_level
  end

  test "PATCH /settings/update_google_calendar_sync rejects invalid directions" do
    @alice.update!(google_access_token: "access", google_refresh_token: "refresh", calendar_sync_level: "two_way")

    patch update_google_calendar_sync_settings_path, params: {direction: "export"}

    assert_response :unprocessable_entity
    assert_equal "two_way", @alice.reload.calendar_sync_level
  end

  test "PATCH /settings/update_google_calendar_sync rejects users without a Google connection" do
    patch update_google_calendar_sync_settings_path, params: {direction: "two_way"}

    assert_response :unprocessable_entity
  end

  test "POST /settings/disconnect_google_calendar clears tokens and resets direction" do
    @alice.update!(google_access_token: "access", google_refresh_token: "refresh",
      google_calendar_email: "user@gmail.com", calendar_sync_level: "two_way")
    success = Net::HTTPSuccess.new("1.1", "200", "OK")
    fake_http = Object.new
    fake_http.define_singleton_method(:request) { |_request| success }
    stub_class_method(Net::HTTP, :start, ->(*_args, **_kwargs, &block) { block.call(fake_http) }) do
      post disconnect_google_calendar_settings_path
    end

    assert_redirected_to calendar_settings_path
    @alice.reload
    assert_nil @alice.google_access_token
    assert_nil @alice.google_calendar_email
    assert_equal "off", @alice.calendar_sync_level
  end

  test "PATCH /settings/calendar saves show_tracked_days" do
    patch update_calendar_settings_path, params: {show_tracked_days: "0"}
    assert_redirected_to calendar_settings_path
    assert_equal false, @alice.reload.show_tracked_days
  end

  test "PATCH /settings updates user language" do
    patch settings_path, params: {user: {language: "de"}}
    assert_redirected_to edit_settings_path
    assert_equal "de", @alice.reload.language
  end

  test "PATCH /settings/update_profile updates name" do
    patch update_profile_settings_path, params: {name: "Alice Updated"}
    assert_redirected_to profile_settings_path
    assert_equal "Alice Updated", @alice.reload.name
  end

  test "all settings pages require authentication" do
    delete session_path
    [edit_settings_path, profile_settings_path, notifications_settings_path].each do |path|
      get path
      assert_redirected_to new_session_path, "Expected #{path} to require auth"
    end
  end

  test "GET /settings/pin returns 200" do
    get pin_settings_path
    assert_response :success
  end

  test "GET /settings/pin shows the no-access-code privacy warning when unset" do
    assert_not @alice.pin_set?
    get pin_settings_path
    assert_match(/haven't set an access code/, CGI.unescapeHTML(response.body))
  end

  test "GET /settings/pin hides the privacy warning once a pin is set" do
    @alice.set_pin("1234")
    get pin_settings_path
    assert_no_match(/haven't set an access code/, CGI.unescapeHTML(response.body))
  end

  test "POST /settings/pin sets pin" do
    assert_not @alice.pin_set?
    post pin_settings_path, params: {pin: "1234", pin_confirmation: "1234"}
    assert_redirected_to profile_settings_path
    assert @alice.reload.pin_set?
  end

  test "POST /settings/pin rejects mismatch" do
    post pin_settings_path, params: {pin: "1234", pin_confirmation: "5678"}
    assert_redirected_to pin_settings_path
    assert_not @alice.reload.pin_set?
  end

  test "DELETE /settings/pin removes pin" do
    @alice.set_pin("1234")
    delete pin_settings_path, params: {pin: "1234"}
    assert_redirected_to profile_settings_path
    assert_not @alice.reload.pin_set?
  end

  test "DELETE /settings/pin with wrong pin does not remove" do
    @alice.set_pin("1234")
    delete pin_settings_path, params: {pin: "9999"}
    assert_redirected_to profile_settings_path
    assert @alice.reload.pin_set?
  end

  test "settings edit page shows unlock modal when PIN is set" do
    @alice.set_pin("1234")
    travel_past_pin_grace do
      get edit_settings_path
      assert_response :success
      assert_includes response.body, "pin-unlock-modal"
    end
  end

  test "PATCH /settings/update_notifications saves a reminder-backed toggle" do
    patch update_notifications_settings_path, params: {cycle_reminder: "1"}, as: :json
    assert_response :success
    reminder = @alice.reminders.find_by(reminder_type: "morning")
    assert reminder.active?
  end

  test "PATCH /settings/update_notifications saves a preference-only toggle" do
    patch update_notifications_settings_path, params: {push_new_appt_synced: "0"}, as: :json
    assert_response :success
    assert_equal false, @alice.reload.notification_preferences["push_new_appt_synced"]
  end

  # Regression test: reminder_type "in_app" (mapped from the email_notifications
  # key) wasn't in Reminder::TYPES, so this request 500'd via an unrescued
  # ActiveRecord::RecordInvalid from reminder.save! — see app/models/reminder.rb.
  test "PATCH /settings/update_notifications saves the in-app popups toggle" do
    patch update_notifications_settings_path, params: {email_notifications: "1"}, as: :json
    assert_response :success
    reminder = @alice.reminders.find_by(reminder_type: "in_app")
    assert reminder.active?
  end

  # M1 — Settings screens should show only the centred calendar FAB
  # (bg-brand-field, aria-label "Go to calendar"), not the "+" quick-actions
  # FAB or the default bottom-right calendar FAB (aria-label
  # "Back to calendar") — supersedes the earlier "+"-only requirement.
  test "GET /settings/profile shows only the centred calendar FAB" do
    get profile_settings_path
    assert_response :success
    assert_no_match(/quick-actions#open/, response.body)
    assert_no_match(/Back to calendar/, response.body)
    assert_match(/Go to calendar/, response.body)
  end

  # The avatar modal is opened from /settings/profile and from /tracking;
  # update_avatar must land the user back where they made the change.
  test "PATCH /settings/update_avatar with return_to tracking redirects to tracking" do
    patch update_avatar_settings_path, params: {avatar_preset: @avatar_preset, return_to: tracking_index_path}
    assert_redirected_to tracking_index_path
    assert_equal @avatar_preset, @alice.reload.avatar_preset
  end

  test "PATCH /settings/update_avatar with return_to profile redirects to profile" do
    patch update_avatar_settings_path, params: {avatar_preset: @avatar_preset, return_to: profile_settings_path}
    assert_redirected_to profile_settings_path
  end

  test "PATCH /settings/update_avatar without return_to falls back to profile" do
    patch update_avatar_settings_path, params: {avatar_preset: @avatar_preset}
    assert_redirected_to profile_settings_path
  end

  test "PATCH /settings/update_avatar ignores a non-whitelisted return_to" do
    patch update_avatar_settings_path, params: {avatar_preset: @avatar_preset, return_to: "https://evil.example.com"}
    assert_redirected_to profile_settings_path
  end

  test "PATCH /settings/update_avatar rejects a non-image file and does not attach it" do
    fake_pdf = Rack::Test::UploadedFile.new(StringIO.new("not an image"), "application/pdf", original_filename: "test.pdf")
    patch update_avatar_settings_path, params: {avatar: fake_pdf}
    assert_not @alice.reload.avatar.attached?
  end

  test "GET /settings/connect_google_calendar uses the v2 endpoint and the configured redirect URI" do
    with_env("GOOGLE_CLIENT_ID", "season-client-id") do
      with_env("GOOGLE_CLIENT_SECRET", "season-client-secret") do
        with_env("GOOGLE_CALENDAR_REDIRECT_URI", "https://seasonv2.onrender.com/settings/google_calendar_callback") do
          get connect_google_calendar_settings_path, params: {direction: "two_way"}
        end
      end
    end

    uri = URI(response.location)
    query = Rack::Utils.parse_query(uri.query)
    assert_equal "accounts.google.com", uri.host
    assert_equal "/o/oauth2/v2/auth", uri.path
    assert_equal "season-client-id", query["client_id"]
    assert_equal "https://seasonv2.onrender.com/settings/google_calendar_callback", query["redirect_uri"]
    assert_equal "https://www.googleapis.com/auth/calendar", query["scope"]
    assert_equal "offline", query["access_type"]
    assert_equal "consent", query["prompt"]
    assert query["state"].present?
    assert_nil session[:google_oauth_state]
    assert_nil session[:google_calendar_sync_direction]
  end

  test "GET /settings/connect_google_calendar uses the canonical redirect URI when env is missing" do
    with_env("GOOGLE_CLIENT_ID", "season-client-id") do
      with_env("GOOGLE_CLIENT_SECRET", "season-client-secret") do
        with_env("GOOGLE_CALENDAR_REDIRECT_URI", nil) do
          get connect_google_calendar_settings_path, headers: {"Host" => "127.0.0.1:3000"}
        end
      end
    end

    uri = URI(response.location)
    query = Rack::Utils.parse_query(uri.query)
    assert_equal "https://seasonv2.onrender.com/settings/google_calendar_callback", query["redirect_uri"]
  end

  test "GET /settings/connect_google_calendar ignores a localhost redirect_uri override in production" do
    with_env("GOOGLE_CLIENT_ID", "season-client-id") do
      with_env("GOOGLE_CLIENT_SECRET", "season-client-secret") do
        with_env("GOOGLE_CALENDAR_REDIRECT_URI", "http://127.0.0.1:3000/settings/google_calendar_callback") do
          env_class = Rails.env.class
          stub_class_method(Rails, :env, -> { env_class.new("production") }) do
            get connect_google_calendar_settings_path
          end
        end
      end
    end

    query = Rack::Utils.parse_query(URI(response.location).query)
    assert_equal "https://seasonv2.onrender.com/settings/google_calendar_callback", query["redirect_uri"]
  end

  test "GET /settings/connect_google_calendar fails gracefully without OAuth credentials" do
    with_env("GOOGLE_CLIENT_ID", nil) do
      with_env("GOOGLE_CLIENT_SECRET", nil) do
        get connect_google_calendar_settings_path
      end
    end

    assert_redirected_to calendar_settings_path
    assert_match(/Failed to connect Google Calendar/, flash[:alert])
  end

  # google_calendar_callback — classic OAuth "connect CSRF": without a state
  # check, an attacker can capture their own authorization code and get a
  # logged-in victim to hit this URL, linking the attacker's Google account
  # to the victim's Season account. Both cases here short-circuit before any
  # real Google API call (state check fails first), so no HTTP mocking needed.
  test "GET /settings/google_calendar_callback rejects a code with no state in session" do
    get google_calendar_callback_settings_path, params: {code: "attacker-code"}
    assert_redirected_to calendar_settings_path
    assert_nil @alice.reload.google_access_token
  end

  test "GET /settings/google_calendar_callback rejects a code with a mismatched state" do
    get connect_google_calendar_settings_path
    get google_calendar_callback_settings_path, params: {code: "attacker-code", state: "wrong-state"}
    assert_redirected_to calendar_settings_path
    assert_nil @alice.reload.google_access_token
  end

  test "GET /settings/google_calendar_callback works when the native browser loses the Rails session" do
    get connect_google_calendar_settings_path, params: {direction: "one_way"}
    state = google_oauth_state_from(response)

    reset!

    good_client = Object.new
    good_client.define_singleton_method(:code=) { |_code| nil }
    good_client.define_singleton_method(:redirect_uri=) { |_uri| nil }
    good_client.define_singleton_method(:fetch_access_token!) { nil }
    good_client.define_singleton_method(:access_token) { "access-token" }
    good_client.define_singleton_method(:refresh_token) { "refresh-token" }
    good_client.define_singleton_method(:expires_at) { 1.hour.from_now.to_i }

    fake_response = Object.new
    fake_response.define_singleton_method(:body) { {email: "alice@example.com"}.to_json }
    fake_http = Object.new
    fake_http.define_singleton_method(:use_ssl=) { |_value| nil }
    fake_http.define_singleton_method(:request) { |_request| fake_response }

    stub_class_method(Signet::OAuth2::Client, :new, ->(*_args, **_kwargs) { good_client }) do
      stub_class_method(Net::HTTP, :new, ->(*_args) { fake_http }) do
        stub_class_method(GoogleCalendarImportService, :call, ->(user:) { 0 }) do
          get google_calendar_callback_settings_path, params: {code: "good-code", state: state}
        end
      end
    end

    assert_redirected_to calendar_settings_path
    assert_equal "access-token", @alice.reload.google_access_token
    assert_equal "one_way", @alice.calendar_sync_level
  end

  # The token exchange (Google rejecting an expired/reused code, or a
  # redirect_uri mismatch) used to raise unhandled out of the callback and
  # surface as a raw 500. It must redirect back to the settings page with
  # the generic failure alert instead, and leave no token behind.
  test "GET /settings/google_calendar_callback redirects gracefully when the token exchange fails" do
    get connect_google_calendar_settings_path
    state = google_oauth_state_from(response)

    bad_client = Object.new
    bad_client.define_singleton_method(:code=) { |_| nil }
    bad_client.define_singleton_method(:redirect_uri=) { |_| nil }
    bad_client.define_singleton_method(:fetch_access_token!) { raise Signet::AuthorizationError, "invalid_grant" }

    stub_class_method(Signet::OAuth2::Client, :new, ->(*_args, **_kwargs) { bad_client }) do
      get google_calendar_callback_settings_path, params: {code: "good-code", state: state}
    end

    assert_redirected_to calendar_settings_path
    assert_nil @alice.reload.google_access_token
  end

  test "POST /settings/sync_google_calendar asks for reconnect when the stored token is rejected" do
    @alice.update!(
      google_access_token: "stale-token",
      google_refresh_token: "refresh-token",
      google_token_expires_at: 1.hour.from_now,
      calendar_sync_level: "two_way"
    )

    stub_class_method(GoogleCalendarImportService, :call, ->(user:) {
      user.update!(google_access_token: nil, google_refresh_token: nil, google_token_expires_at: nil)
      0
    }) do
      post sync_google_calendar_settings_path
    end

    assert_redirected_to calendar_settings_path
    assert_match(/reconnect/i, flash[:alert])
  end

  test "POST /settings/sync_google_calendar imports only for one-way sync" do
    @alice.update!(
      google_access_token: "access",
      google_refresh_token: "refresh",
      calendar_sync_level: "one_way"
    )
    @alice.calendar_events.create!(title: "Dentist", date: Date.current)

    stub_class_method(GoogleCalendarImportService, :call, ->(user:) { 2 }) do
      assert_no_enqueued_jobs(only: GoogleCalendarPushJob) do
        post sync_google_calendar_settings_path
      end
    end

    assert_redirected_to calendar_settings_path
    assert_match(/2/, flash[:notice])
  end

  test "POST /settings/sync_google_calendar handles import failures without 500" do
    @alice.update!(
      google_access_token: "access",
      google_refresh_token: "refresh",
      calendar_sync_level: "one_way"
    )

    stub_class_method(GoogleCalendarImportService, :call, ->(user:) { raise "Google Calendar API down" }) do
      post sync_google_calendar_settings_path
    end

    assert_redirected_to calendar_settings_path
    assert_match(/failed/i, flash[:alert])
  end

  test "POST /settings/sync_google_calendar backfills Season events for two-way sync" do
    @alice.update!(
      google_access_token: "access",
      google_refresh_token: "refresh",
      calendar_sync_level: "two_way"
    )
    event = @alice.calendar_events.create!(title: "Dentist", date: Date.current)

    stub_class_method(GoogleCalendarImportService, :call, ->(user:) { 2 }) do
      assert_enqueued_with(job: GoogleCalendarPushJob, args: ["create", {user_id: @alice.id, calendar_event_id: event.id}]) do
        post sync_google_calendar_settings_path
      end
    end

    assert_redirected_to calendar_settings_path
    assert_match(/2/, flash[:notice])
  end

  test "GET /settings/google_calendar_callback handles import failures without 500" do
    get connect_google_calendar_settings_path, params: {direction: "two_way"}
    state = google_oauth_state_from(response)

    good_client = Object.new
    good_client.define_singleton_method(:code=) { |_code| nil }
    good_client.define_singleton_method(:redirect_uri=) { |_uri| nil }
    good_client.define_singleton_method(:fetch_access_token!) { nil }
    good_client.define_singleton_method(:access_token) { "access-token" }
    good_client.define_singleton_method(:refresh_token) { "refresh-token" }
    good_client.define_singleton_method(:expires_at) { 1.hour.from_now.to_i }

    fake_response = Object.new
    fake_response.define_singleton_method(:body) { {email: "alice@example.com"}.to_json }
    fake_http = Object.new
    fake_http.define_singleton_method(:use_ssl=) { |_value| nil }
    fake_http.define_singleton_method(:request) { |_request| fake_response }

    stub_class_method(Signet::OAuth2::Client, :new, ->(*_args, **_kwargs) { good_client }) do
      stub_class_method(Net::HTTP, :new, ->(*_args) { fake_http }) do
        stub_class_method(GoogleCalendarImportService, :call, ->(user:) { raise "Google Calendar API down" }) do
          get google_calendar_callback_settings_path, params: {code: "good-code", state: state}
        end
      end
    end

    assert_redirected_to calendar_settings_path
    assert_match(/failed/i, flash[:alert])
    assert_equal "access-token", @alice.reload.google_access_token
  end

  test "GET /settings/google_calendar_callback imports events and backfills two-way sync" do
    event = @alice.calendar_events.create!(title: "Dentist", date: Date.current)
    get connect_google_calendar_settings_path, params: {direction: "two_way"}
    state = google_oauth_state_from(response)

    good_client = Object.new
    good_client.define_singleton_method(:code=) { |_code| nil }
    good_client.define_singleton_method(:redirect_uri=) { |_uri| nil }
    good_client.define_singleton_method(:fetch_access_token!) { nil }
    good_client.define_singleton_method(:access_token) { "access-token" }
    good_client.define_singleton_method(:refresh_token) { "refresh-token" }
    good_client.define_singleton_method(:expires_at) { 1.hour.from_now.to_i }

    fake_response = Object.new
    fake_response.define_singleton_method(:body) { {email: "alice@example.com"}.to_json }
    fake_http = Object.new
    fake_http.define_singleton_method(:use_ssl=) { |_value| nil }
    fake_http.define_singleton_method(:request) { |_request| fake_response }

    assert_enqueued_with(job: GoogleCalendarPushJob, args: ["create", {user_id: @alice.id, calendar_event_id: event.id}]) do
      stub_class_method(Signet::OAuth2::Client, :new, ->(*_args, **_kwargs) { good_client }) do
        stub_class_method(Net::HTTP, :new, ->(*_args) { fake_http }) do
          stub_class_method(GoogleCalendarImportService, :call, ->(user:) {
            @imported_user_id = user.id
            2
          }) do
            get google_calendar_callback_settings_path, params: {code: "good-code", state: state}
          end
        end
      end
    end

    assert_equal @alice.id, @imported_user_id
    assert_equal "access-token", @alice.reload.google_access_token
    assert_equal "two_way", @alice.reload.calendar_sync_level
    assert_match(/2/, flash[:notice])
  end

  # AUTH-04 follow-up: update_password re-issues login() so the device that
  # just proved its identity (via current_password below) doesn't end up
  # signed out by its own action once its session cookie eventually expires
  # and it falls back to the now-fingerprint-checked persistent cookie.
  test "PATCH /settings/update_password keeps the current device signed in past the old session boundary" do
    patch update_password_settings_path, params: {
      current_password: "password123",
      password: "NewPassword456!",
      password_confirmation: "NewPassword456!"
    }
    assert_redirected_to profile_settings_path

    travel_to 10.days.from_now do
      get tracking_index_path
      assert_response :success
    end
  end

  private

  def google_oauth_state_from(response)
    Rack::Utils.parse_query(URI(response.location).query).fetch("state")
  end
end
