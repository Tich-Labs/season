require "test_helper"

# M3 — Streaks
class StreaksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    sign_in_as(@alice)
  end

  test "GET /streaks returns 200" do
    get streaks_path
    assert_response :success
  end

  test "GET /streaks requires authentication" do
    delete session_path
    get streaks_path
    assert_redirected_to new_session_path
  end

  test "GET /streaks shows current streak value" do
    streak = @alice.streak || @alice.create_streak(current_streak: 7, longest_streak: 7, total_flames: 7)
    streak.update!(current_streak: 7)
    get streaks_path
    assert_match "7", response.body
  end
end
