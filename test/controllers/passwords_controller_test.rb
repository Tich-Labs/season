require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
  end

  # --- GET /users/password/edit ---

  test "GET edit with a valid reset token renders the form" do
    token = @alice.send_reset_password_instructions

    get edit_user_password_path(reset_password_token: token)
    assert_response :success
  end

  test "GET edit with an invalid token redirects to link-expired" do
    get edit_user_password_path(reset_password_token: "not-a-real-token")
    assert_redirected_to password_error_link_expired_path
  end

  test "GET edit with a blank token redirects to link-expired" do
    get edit_user_password_path(reset_password_token: "")
    assert_redirected_to password_error_link_expired_path
  end

  test "GET edit with an expired token redirects to link-expired" do
    token = @alice.send_reset_password_instructions

    travel_to 3.hours.from_now do
      get edit_user_password_path(reset_password_token: token)
      assert_redirected_to password_error_link_expired_path
    end
  end

  # --- PATCH /users/password (update) ---

  test "PATCH update with a valid token and matching passwords resets the password and logs in" do
    token = @alice.send_reset_password_instructions

    patch user_password_path, params: {
      reset_password_token: token,
      password: "BrandNewPass456!",
      password_confirmation: "BrandNewPass456!"
    }

    assert_redirected_to user_root_path
    assert @alice.reload.valid_password?("BrandNewPass456!")

    # Logged in as a side effect of a successful reset.
    follow_redirect!
    assert_response :success
  end

  test "PATCH update with an invalid token redirects to link-expired without changing the password" do
    patch user_password_path, params: {
      reset_password_token: "not-a-real-token",
      password: "BrandNewPass456!",
      password_confirmation: "BrandNewPass456!"
    }

    assert_redirected_to password_error_link_expired_path
    assert @alice.reload.valid_password?("password123")
  end

  test "PATCH update with an expired token redirects to link-expired without changing the password" do
    token = @alice.send_reset_password_instructions

    travel_to 3.hours.from_now do
      patch user_password_path, params: {
        reset_password_token: token,
        password: "BrandNewPass456!",
        password_confirmation: "BrandNewPass456!"
      }
      assert_redirected_to password_error_link_expired_path
    end

    assert @alice.reload.valid_password?("password123")
  end

  test "PATCH update with mismatched confirmation re-renders the form with an error" do
    token = @alice.send_reset_password_instructions

    patch user_password_path, params: {
      reset_password_token: token,
      password: "BrandNewPass456!",
      password_confirmation: "SomethingElse789!"
    }

    assert_response :unprocessable_content
    assert_match(/confirmation/i, CGI.unescapeHTML(response.body))
    assert_match(/match/i, CGI.unescapeHTML(response.body))
    assert @alice.reload.valid_password?("password123"), "password should be unchanged on validation failure"
  end

  test "PATCH update with a too-short password re-renders the form with an error" do
    token = @alice.send_reset_password_instructions

    patch user_password_path, params: {
      reset_password_token: token,
      password: "abc",
      password_confirmation: "abc"
    }

    assert_response :unprocessable_content
    assert @alice.reload.valid_password?("password123"), "password should be unchanged on validation failure"
  end

  # --- POST /users/password (create — the "forgot password" request itself) ---

  test "POST create does not reveal whether an email exists (unknown email)" do
    post user_password_path, params: {email: "nobody-at-all@example.com"}
    assert_redirected_to done_password_path
  end

  test "a reset token can only be used once" do
    token = @alice.send_reset_password_instructions

    patch user_password_path, params: {
      reset_password_token: token,
      password: "BrandNewPass456!",
      password_confirmation: "BrandNewPass456!"
    }
    assert_redirected_to user_root_path

    # Devise clears the token on successful reset — reusing it should now fail like any other invalid token.
    patch user_password_path, params: {
      reset_password_token: token,
      password: "AnotherPass789!",
      password_confirmation: "AnotherPass789!"
    }
    assert_redirected_to password_error_link_expired_path
    assert @alice.reload.valid_password?("BrandNewPass456!")
  end
end
