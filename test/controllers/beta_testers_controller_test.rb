require "test_helper"

class BetaTestersControllerTest < ActionDispatch::IntegrationTest
  VALID = {
    name: "Alice Tester",
    email: "alice@example.com",
    platform: "ios",
    beta_consent: "1"
  }.freeze

  test "beta page loads with the two-column form" do
    get beta_path

    assert_response :success
    assert_select "h1", /Become a beta tester/
    assert_select "form"
    assert_select "input[name=?][value=?]", "beta_tester[platform]", "ios"
  end

  test "beta page is not indexable" do
    get beta_path

    assert_response :success
    assert_match(/noindex/i, response.headers["X-Robots-Tag"].to_s)
    assert_select "meta[name=robots][content*=noindex]"
  end

  # Rails 8 dropped form_with's `local:` option entirely — it is silently
  # ignored, leaving Turbo to intercept the submit. Turbo requires a redirect
  # and raises "Form responses must redirect to another location" against our
  # state-rendering 200, which shows the user nothing at all.
  test "form opts out of Turbo so a non-redirect response renders" do
    get beta_path

    assert_response :success
    assert_select "form[data-turbo=false]", 1
  end

  test "beta page does not require sign in" do
    get beta_path

    assert_response :success
  end

  test "successful registration replaces the form with a confirmation" do
    assert_difference -> { BetaTester.count }, 1 do
      post beta_path, params: {beta_tester: VALID}
    end

    assert_response :success
    assert_select "[data-testid=beta-confirmation]"
    assert_no_match(/Let&#39;s go/, response.body)
    assert_select "form", false
  end

  test "duplicate registration shows the already-registered state without creating a row" do
    BetaTester.create!(name: "Alice Tester", email: "alice@example.com", platform: "ios", beta_consent: true)

    assert_no_difference -> { BetaTester.count } do
      post beta_path, params: {
        beta_tester: VALID.merge(name: "Someone Else", email: "ALICE@EXAMPLE.COM", platform: "android")
      }
    end

    # A duplicate is terminal, not a failure — 422 would invite a retry that
    # can never succeed, so this responds 200 with the form swapped out.
    assert_response :success
    assert_select "[data-testid=beta-duplicate]"
    assert_select "form", false
    assert_match(/already registered/i, response.body)
    assert_match(/spam/i, response.body)
  end

  test "invalid input re-renders an editable form with 422" do
    assert_no_difference -> { BetaTester.count } do
      post beta_path, params: {beta_tester: {email: "nope", name: ""}}
    end

    assert_response :unprocessable_content
    assert_select "form"
    assert_select "[data-testid=beta-duplicate]", false
    assert_select "[data-testid=beta-confirmation]", false
    assert_match(/Please check the highlighted fields/, response.body)
  end

  test "consent checkbox is required" do
    assert_no_difference -> { BetaTester.count } do
      post beta_path, params: {beta_tester: VALID.except(:beta_consent)}
    end

    assert_response :unprocessable_content
    assert_match(/must be accepted/, response.body)
  end

  test "admin consent copy is rendered on the form" do
    BetaTesterSetting.current.update!(consent_label: "I agree to the {LINK}.")

    get beta_path

    assert_response :success
    assert_match(/I agree to the/, response.body)
  end

  # The Beta information page does not exist yet, so the default link target is
  # "#" (goes nowhere) rather than a path that 404s.
  test "consent link defaults to a placeholder target" do
    get beta_path

    assert_response :success
    assert_select 'a[href="#"]', text: /Beta Test Information/
    assert_select 'a[href="/information"]', false
  end
end
