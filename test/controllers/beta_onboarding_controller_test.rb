# frozen_string_literal: true

require "test_helper"

class BetaOnboardingControllerTest < ActionDispatch::IntegrationTest
  setup do
    @locale = "en"
  end

  # ── Step 1: consent ───────────────────────────────────────────────────────

  test "GET /beta renders the first screen" do
    get beta_path(locale: @locale)
    assert_response :success
    assert_match "Before you start", response.body
  end

  test "GET /beta defaults to German" do
    get beta_path
    assert_response :success
    assert_match "Bevor du startest", response.body
  end

  test "GET /beta is noindex" do
    get beta_path(locale: @locale)
    assert_equal "noindex, nofollow", response.headers["X-Robots-Tag"]
  end

  test "first screen shows the four disclosure points" do
    get beta_path(locale: @locale)
    assert_match "not a medical device", response.body
    assert_match "No selling, no advertising, no AI training", response.body
    assert_match "not yet end-to-end encrypted", response.body
    assert_match "delete your account at any time", response.body
  end

  test "first screen labels the required and optional consents" do
    get beta_path(locale: @locale)
    assert_match "Required", response.body
    assert_match "Optional", response.body
  end

  test "first screen links to the full privacy notice and back to this step" do
    get beta_path(locale: @locale)
    # assert_select rather than assert_match: the href is HTML-escaped (&amp;)
    assert_select "a[href=?]", legal_path(type: "privacy", locale: @locale, from: "consent")
  end

  test "the disclosure points use Season icons, not emoji" do
    get beta_path(locale: @locale)
    assert_match "beta-points__icon", response.body
    assert_no_match(/⚕|🔒|🧪|🚪/, response.body)
  end

  # ── Consent gating ────────────────────────────────────────────────────────

  test "POST /beta/consent without the required consent does not advance" do
    post beta_path(locale: @locale), params: {consent: {health_consent: "0", survey_opt_in: "1"}}
    assert_redirected_to beta_path(locale: @locale)
    assert_nil session[:health_consent]
  end

  test "POST /beta/consent with health consent advances to registration" do
    post beta_path(locale: @locale), params: {consent: {health_consent: "1", survey_opt_in: "0"}}
    assert_redirected_to beta_register_path(locale: @locale)
    assert session[:health_consent].present?
  end

  test "POST /beta/consent records survey opt-in in the session" do
    post beta_path(locale: @locale), params: {consent: {health_consent: "1", survey_opt_in: "1"}}
    assert_equal true, session[:survey_opt_in]
  end

  # An explicit false is stored rather than nil so the ledger can tell
  # "declined" apart from "never asked" — neither grants anything.
  test "POST /beta/consent records an unticked survey box as declined, not granted" do
    post beta_path(locale: @locale), params: {consent: {health_consent: "1", survey_opt_in: "0"}}
    assert_equal false, session[:survey_opt_in]
  end

  # ── Step 2: registration ──────────────────────────────────────────────────

  test "GET /beta/register without prior consent redirects back to consent" do
    get beta_register_path(locale: @locale)
    assert_redirected_to beta_path(locale: @locale)
  end

  test "GET /beta/register renders after consent" do
    post beta_path(locale: @locale), params: {consent: {health_consent: "1", survey_opt_in: "0"}}
    get beta_register_path(locale: @locale)
    assert_response :success
    assert_match "Become a beta tester", response.body
  end

  test "registration screen offers the three devices" do
    post beta_path(locale: @locale), params: {consent: {health_consent: "1", survey_opt_in: "0"}}
    get beta_register_path(locale: @locale)
    assert_match "Apple iOS", response.body
    assert_match "Android", response.body
    assert_match "Web", response.body
  end

  test "registration screen has one combined 18+ / terms / privacy checkbox" do
    post beta_path(locale: @locale), params: {consent: {health_consent: "1", survey_opt_in: "0"}}
    get beta_register_path(locale: @locale)
    assert_match "beta_tester[terms_accepted]", response.body
    assert_match "at least 18 years old", response.body
  end

  test "POST /beta/register without prior consent does not create a tester" do
    assert_no_difference -> { BetaTester.count } do
      post beta_register_path(locale: @locale), params: {beta_tester: valid_registration}
    end
    assert_redirected_to beta_path(locale: @locale)
  end

  # ── Step 3: confirmation + ledger ─────────────────────────────────────────

  test "successful registration creates a tester marked as consented" do
    complete_consent
    post beta_register_path(locale: @locale), params: {beta_tester: valid_registration}
    assert_redirected_to beta_confirmed_path(locale: @locale, platform: "ios")
    assert_equal true, BetaTester.order(:id).last.beta_consent
  end

  test "successful registration writes four separate consent records" do
    complete_consent
    assert_difference -> { ConsentRecord.count } => 4 do
      post beta_register_path(locale: @locale), params: {beta_tester: valid_registration}
    end
  end

  test "consent records cover the four distinct consent types" do
    complete_consent
    post beta_register_path(locale: @locale), params: {beta_tester: valid_registration}
    assert_equal %w[age_18 health_data survey_contact terms], records_for_newest_tester.pluck(:consent_type).sort
  end

  test "survey refusal is recorded as a refusal, not a grant" do
    complete_consent(survey: "0")
    post beta_register_path(locale: @locale), params: {beta_tester: valid_registration}
    record = latest_record("survey_contact")
    assert_equal false, record.granted
  end

  test "survey opt-in is recorded as a grant" do
    complete_consent(survey: "1")
    post beta_register_path(locale: @locale), params: {beta_tester: valid_registration}
    record = latest_record("survey_contact")
    assert_equal true, record.granted
  end

  test "each consent record stores the agreed language" do
    complete_consent
    post beta_register_path(locale: @locale), params: {beta_tester: valid_registration}
    assert_equal ["en"], records_for_newest_tester.pluck(:language).uniq
  end

  test "each consent record stores a sha256 of the shown text" do
    complete_consent
    post beta_register_path(locale: @locale), params: {beta_tester: valid_registration}
    records_for_newest_tester.each do |record|
      assert_match(/\A[0-9a-f]{64}\z/, record.text_sha256)
    end
  end

  test "German registration records German on the consent rows" do
    post beta_path(locale: "de"), params: {consent: {health_consent: "1", survey_opt_in: "0"}}
    post beta_register_path(locale: "de"), params: {beta_tester: valid_registration}
    assert_equal ["de"], records_for_newest_tester.pluck(:language).uniq
  end

  test "registration without accepting terms creates no tester" do
    complete_consent
    params = valid_registration.merge(terms_accepted: "0", age_confirmed: "0")
    assert_no_difference -> { BetaTester.count } do
      post beta_register_path(locale: @locale), params: {beta_tester: params}
    end
    assert_response :unprocessable_entity
  end

  test "consent session is cleared after successful registration" do
    complete_consent
    post beta_register_path(locale: @locale), params: {beta_tester: valid_registration}
    assert_nil session[:health_consent]
    assert_nil session[:survey_opt_in]
  end

  test "confirmation screen shows the steps for the chosen device" do
    get beta_confirmed_path(locale: @locale, platform: "ios")
    assert_response :success
    assert_match "Getting started on Apple iOS", response.body
  end

  test "web confirmation links out to the web app" do
    get beta_confirmed_path(locale: @locale, platform: "web")
    assert_match "Open the web app", response.body
  end

  test "mobile confirmations do not link to the web app" do
    get beta_confirmed_path(locale: @locale, platform: "android")
    assert_no_match(/Open the web app/, response.body)
  end

  test "iOS confirmation links to the TestFlight public link when configured" do
    with_env("TESTFLIGHT_PUBLIC_LINK", "https://testflight.apple.com/join/ABC") do
      get beta_confirmed_path(locale: @locale, platform: "ios")
      assert_match "Open in TestFlight", response.body
      assert_match "https://testflight.apple.com/join/ABC", response.body
    end
  end

  test "Android confirmation links to the Play testing link when configured" do
    with_env("GOOGLE_PLAY_OPEN_TESTING_URL", "https://play.google.com/apps/testing/com.onrender.seasonv2.rubynative") do
      get beta_confirmed_path(locale: @locale, platform: "android")
      assert_match "Open in Google Play", response.body
      assert_match "https://play.google.com/apps/testing/com.onrender.seasonv2.rubynative", response.body
    end
  end

  test "Android confirmation shows the Google Group link when configured" do
    with_env("GOOGLE_PLAY_GROUP_URL", "https://groups.google.com/g/season2_beta_tester/") do
      get beta_confirmed_path(locale: @locale, platform: "android")
      assert_match "Join the tester group", response.body
      assert_match "https://groups.google.com/g/season2_beta_tester/", response.body
    end
  end

  test "iOS confirmation shows no download button when the link is not configured" do
    with_env("TESTFLIGHT_PUBLIC_LINK", nil) do
      get beta_confirmed_path(locale: @locale, platform: "ios")
      assert_no_match(/Open in TestFlight/, response.body)
      assert_match "We will email you an invitation", response.body
    end
  end

  # ── Regression: the logo is the only brand mark on every card ─────────────

  test "no card renders a 'SEASON V2' text title" do
    get beta_path(locale: @locale)
    assert_no_match(/SEASON V2/, response.body)

    complete_consent
    get beta_register_path(locale: @locale)
    assert_no_match(/SEASON V2/, response.body)

    get beta_confirmed_path(locale: @locale, platform: "ios")
    assert_no_match(/SEASON V2/, response.body)
  end

  test "every card shows the stacked brand lockup exactly once" do
    get beta_path(locale: @locale)
    assert_lockup

    complete_consent
    get beta_register_path(locale: @locale)
    assert_lockup

    get beta_confirmed_path(locale: @locale, platform: "ios")
    assert_lockup
  end

  # Both brand marks ship as dark red on transparent, which is 2.4:1 on the dark
  # card — effectively invisible. Logos are exempt from the WCAG 3:1 non-text
  # floor, so the fix is dark-mode only: invert the lockup like the icon set.
  test "the brand lockup is inverted in dark mode" do
    css = Rails.root.join("app/assets/tailwind/application.css").read
    dark_block = css[/@media \(prefers-color-scheme: dark\).*?\n\}/m]

    assert_match(/\.beta-logo-stack\s*\{\s*filter:\s*invert\(1\)/, dark_block)
  end

  # The lockup must not be allowed to grow back to the size that unbalances the
  # card (234x255 graphic + 280px wordmark).
  test "the brand lockup stays within its balanced size budget" do
    get beta_path(locale: @locale)

    assert_select ".beta-logo-stack img:first-child" do |imgs|
      assert_equal %w[200px 218px], imgs.first["class"].scan(/[wh]-\[(\d+px)\]/).flatten
    end
    assert_select ".beta-logo-stack img:last-child" do |imgs|
      assert_includes imgs.first["class"], "w-[240px]"
    end
  end

  private

  def assert_lockup
    assert_select ".beta-logo-stack", 1
    assert_select ".beta-logo-stack img", 2
  end

  def complete_consent(survey: "0")
    post beta_path(locale: @locale), params: {consent: {health_consent: "1", survey_opt_in: survey}}
  end

  def records_for_newest_tester
    ConsentRecord.where(beta_tester: BetaTester.order(:id).last)
  end

  def latest_record(consent_type)
    records_for_newest_tester.find_by!(consent_type: consent_type)
  end

  # ── Regression: the browser only ever posts one checkbox ───────────────────

  test "registration succeeds when only terms_accepted is posted (combined checkbox)" do
    complete_consent
    # Mirrors the rendered form exactly: the single combined checkbox submits
    # terms_accepted, and nothing named age_confirmed exists in the markup.
    post beta_register_path(locale: @locale), params: {beta_tester: {
      name: "Robin Test",
      email: "robin.test@example.com",
      platform: "iOS",
      terms_accepted: "1"
    }}
    assert_response :redirect
    assert_equal 1, BetaTester.where(email: "robin.test@example.com").count
    assert latest_record("terms").granted?
    assert latest_record("age_18").granted?
  end

  test "registration form renders a single combined checkbox (no age_confirmed field)" do
    complete_consent
    get beta_register_path(locale: @locale)
    assert_match "beta_tester[terms_accepted]", response.body
    assert_no_match(/name="beta_tester\[age_confirmed\]"/, response.body)
  end

  def valid_registration
    {
      name: "Robin Test",
      email: "robin.test@example.com",
      platform: "iOS",
      terms_accepted: "1",
      age_confirmed: "1"
    }
  end

  # The tick and the confirmation message must read as one line, sharing the
  # heading's size and colour, instead of a 38px tick floating above the h1.
  test "the confirmation tick shares the heading line, size and colour" do
    get beta_confirmed_path(locale: @locale, platform: "ios")

    assert_select "h1.beta-h1--inline" do |heads|
      assert_equal 1, heads.size
      tick = heads.first.at_css(".beta-check-mark")
      assert_not_nil tick, "the tick must live inside the heading"
      assert_equal "span", tick.name, "the tick must not be a block element"
      assert_equal "true", tick["aria-hidden"], "the tick is decorative"
    end

    css = Rails.root.join("app/assets/tailwind/application.css").read
    inline = css[/\.beta-h1--inline\s*\{[^}]*\}/]
    assert_includes inline, "font-size: 17px"
    assert_includes inline, "display: flex"
    # font-size: 1em keeps the tick locked to whatever the heading resolves to.
    assert_includes css[/\.beta-h1--inline \.beta-check-mark\s*\{[^}]*\}/], "font-size: 1em"
  end
end
