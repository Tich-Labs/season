# frozen_string_literal: true

require "test_helper"

class AccountDeletionControllerTest < ActionDispatch::IntegrationTest
  test "GET /account/delete renders the request form" do
    get account_deletion_path
    assert_response :success
    assert_match "Delete your account", response.body
  end

  test "the request page is noindex" do
    get account_deletion_path
    assert_equal "noindex, nofollow", response.headers["X-Robots-Tag"]
  end

  test "POST with an invalid email re-renders the form with an error" do
    post account_deletion_path, params: {account_deletion: {email: "not-an-email"}}
    assert_response :unprocessable_entity
    assert_match "valid email", response.body
  end

  test "POST with a matching email enqueues the deletion email and redirects" do
    assert_enqueued_emails 1 do
      post account_deletion_path, params: {account_deletion: {email: "alice@example.com"}}
    end
    assert_redirected_to account_deletion_sent_path
  end

  test "POST with an unknown email redirects without revealing whether it exists" do
    assert_no_enqueued_emails do
      post account_deletion_path, params: {account_deletion: {email: "ghost@example.com"}}
    end
    assert_redirected_to account_deletion_sent_path
  end

  test "confirm with a valid token deletes the account" do
    token = users(:alice).signed_id(purpose: :account_deletion, expires_in: 1.hour)

    assert_difference -> { User.count }, -1 do
      get account_deletion_confirm_path(token: token)
    end

    assert_response :success
    assert_match "Account deleted", response.body
  end

  test "confirm with an invalid token does not delete anything" do
    assert_no_difference -> { User.count } do
      get account_deletion_confirm_path(token: "bogus")
    end

    assert_response :success
    assert_match "Link expired or invalid", response.body
  end
end
