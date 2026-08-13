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
