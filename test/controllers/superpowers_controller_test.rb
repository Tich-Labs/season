require "test_helper"

# M3 — Superpowers
class SuperpowersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    sign_in_as(@alice)
  end

  test "GET /superpowers returns 200" do
    get superpowers_path
    assert_response :success
  end

  test "GET /superpowers requires authentication" do
    delete session_path
    get superpowers_path
    assert_redirected_to new_session_path
  end

  test "GET /superpowers/:id returns 200 for a valid log id" do
    get superpower_path(superpower_logs(:alice_log_a))
    assert_response :success
  end

  test "GET /superpowers/:id returns 200 for another log" do
    get superpower_path(superpower_logs(:alice_log_b))
    assert_response :success
  end
end
