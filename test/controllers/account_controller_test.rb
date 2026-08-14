require "test_helper"

# Regression coverage for the /account (Delete Account) route. It used to 406
# on every visit: `resource :account` defaulted to the plural AccountsController
# by Rails convention, which was an empty stub with no view — silently shadowing
# the real, fully-built AccountController. Fixed by adding an explicit
# `controller: "account"` override in routes.rb and deleting the dead stub.
class AccountControllerTest < ActionDispatch::IntegrationTest
  def onboarded_user(email:)
    User.create!(
      email: email, name: "Test", password: "CorrectHorse123!", password_confirmation: "CorrectHorse123!",
      birthday: 30.years.ago, has_regular_cycle: true, uses_hormonal_birth_control: false,
      food_preference: "omnivore", onboarding_completed: true
    ).tap(&:confirm)
  end

  test "GET /account renders the delete-confirmation page" do
    user = onboarded_user(email: "accounttest1@example.com")
    sign_in_as(user, password: "CorrectHorse123!")

    get account_path
    assert_response :success
    assert_match "Delete My Account", response.body
  end

  test "GET /account requires authentication" do
    get account_path
    assert_redirected_to new_session_path
  end

  # AccountController isn't under the settings/ namespace, so it doesn't get
  # the dark header for free the way settings/* pages do -- was rendering
  # light (bg-brand-field) with a white back-arrow icon, nearly invisible
  # against it.
  test "GET /account gets the branded dark header, not the light default" do
    user = onboarded_user(email: "accounttest4@example.com")
    sign_in_as(user, password: "CorrectHorse123!")

    get account_path
    assert_match(/bg-brand-primary/, response.body)
    assert_match(">Delete Account<", response.body)
  end

  # Its only real entry point is settings/profile.html.erb's "Delete Account"
  # row -- back and cancel were both hardcoded to edit_settings_path instead.
  test "GET /account back and cancel links reflect the settings profile referer" do
    user = onboarded_user(email: "accounttest5@example.com")
    sign_in_as(user, password: "CorrectHorse123!")

    get account_path, headers: {"HTTP_REFERER" => profile_settings_url}
    assert_match %r{href="/settings/profile"}, response.body
  end

  test "GET /account back and cancel links fall back to settings profile with no referer" do
    user = onboarded_user(email: "accounttest6@example.com")
    sign_in_as(user, password: "CorrectHorse123!")

    get account_path
    assert_match %r{href="/settings/profile"}, response.body
  end

  # Regression for a real reported bug: /account's back link used to trust
  # *any* same-origin referer. Since /settings/profile also dynamically
  # resolves its own back link from its referer, leaving /account back to
  # profile made /account the referer for that load -- so profile's back
  # link pointed at /account, and the two pages ping-ponged forever. /account
  # only has one real entry point (settings/profile.html.erb), so it should
  # never trust a different referer even if same-origin.
  test "GET /account ignores an untrusted same-origin referer" do
    user = onboarded_user(email: "accounttest7@example.com")
    sign_in_as(user, password: "CorrectHorse123!")

    get account_path, headers: {"HTTP_REFERER" => edit_settings_url}
    # The burger menu (present on every page) has its own unrelated "Settings"
    # link to /settings/edit, so scope this to the header's back-link specifically.
    assert_select "header a[href='/settings/profile']"
    assert_select "header a[href='/settings/edit']", false
  end

  test "DELETE /account destroys the user, logs out, and redirects with a flash notice" do
    user = onboarded_user(email: "accounttest2@example.com")
    sign_in_as(user, password: "CorrectHorse123!")

    assert_difference("User.count", -1) do
      delete account_path
    end
    assert_redirected_to root_path
    assert_equal "Your account has been deleted.", flash[:notice]

    follow_redirect!
    assert_not_includes response.request.path, "account"
  end

  test "GET /account/export returns a JSON data export" do
    user = onboarded_user(email: "accounttest3@example.com")
    sign_in_as(user, password: "CorrectHorse123!")

    get export_account_path, as: :json
    assert_response :success
    assert_equal "application/json", response.media_type
    json = response.parsed_body
    assert_equal user.email, json["user"]["email"]
  end
end
