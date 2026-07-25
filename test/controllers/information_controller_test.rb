require "test_helper"

# M3 — Phase Education (Information)
class InformationControllerTest < ActionDispatch::IntegrationTest
  def setup
    sign_in_as(users(:alice))
  end

  test "GET /information returns 200" do
    get information_path
    assert_response :success
  end

  test "GET /information back link falls back to calendar when there's no history" do
    get information_path
    assert_match(/window\.history\.length > 1.*window\.history\.back\(\)/, response.body)
    assert_match(/href="#{Regexp.escape(user_root_path)}"/, response.body)
  end

  test "GET /information requires authentication" do
    delete session_path
    get information_path
    assert_redirected_to new_session_path
  end

  %w[menstrual follicular ovulation luteal].each do |phase|
    test "GET /information/#{phase} returns 200" do
      get information_phase_path(phase)
      assert_response :success
    end
  end

  test "GET /information/:phase back link falls back to phase list when there's no history" do
    get information_phase_path("menstrual")
    assert_match(/window\.history\.length > 1.*window\.history\.back\(\)/, response.body)
    assert_match(/href="#{Regexp.escape(information_path)}"/, response.body)
  end

  test "GET /information/:phase with invalid phase redirects to index" do
    get information_phase_path("unknown")
    assert_redirected_to information_path
  end
end
