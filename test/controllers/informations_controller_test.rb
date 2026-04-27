require "test_helper"

# M3 — Phase Education (Informations)
class InformationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    sign_in_as(users(:alice))
  end

  test "GET /informations returns 200" do
    get informations_path
    assert_response :success
  end

  test "GET /informations requires authentication" do
    delete session_path
    get informations_path
    assert_redirected_to new_session_path
  end

  %w[menstrual follicular ovulation luteal].each do |phase|
    test "GET /informations/#{phase} returns 200" do
      get informations_phase_path(phase)
      assert_response :success
    end
  end

  test "GET /informations/:phase with invalid phase redirects to index" do
    get informations_phase_path("unknown")
    assert_redirected_to informations_path
  end
end
