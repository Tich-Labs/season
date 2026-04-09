require "test_helper"

class InvitesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @invited = users(:invited_user)
    @used_invite = users(:used_invite_user)
  end

  # --- GET /invite/:token (show) ---

  test "GET /invite/:token with valid unused token returns 200" do
    get invite_path(token: @invited.invite_token)
    assert_response :success
  end

  test "GET /invite/:token with invalid token redirects to root with alert" do
    get invite_path(token: "nonexistent_token_xyz")
    assert_redirected_to root_path
  end

  test "GET /invite/:token with already-used token redirects to login with alert" do
    get invite_path(token: @used_invite.invite_token)
    assert_redirected_to new_session_path
  end

  # --- PATCH /invite/:token (update) ---

  test "PATCH /invite/:token with valid password signs in user and redirects to onboarding" do
    patch invite_path(token: @invited.invite_token),
      params: {password: "newpassword123"}
    assert_redirected_to onboarding_path(1)
  end

  test "PATCH /invite/:token marks invite as accepted" do
    assert_nil @invited.invite_accepted_at
    patch invite_path(token: @invited.invite_token),
      params: {password: "newpassword123"}
    @invited.reload
    assert_not_nil @invited.invite_accepted_at
  end

  test "PATCH /invite/:token clears the invite_token after acceptance" do
    patch invite_path(token: @invited.invite_token),
      params: {password: "newpassword123"}
    @invited.reload
    assert_nil @invited.invite_token
  end

  test "PATCH /invite/:token with invalid token redirects to root" do
    patch invite_path(token: "bogus_token"),
      params: {password: "newpassword123"}
    assert_redirected_to root_path
  end
end
