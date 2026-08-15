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

  test "cannot view another user's superpower log" do
    bob_log = users(:bob).superpower_logs.create!(date: Time.zone.today, ratings: {})
    get superpower_path(bob_log)
    assert_response :not_found
  end

  # Date guard — index
  test "GET /superpowers with valid date param returns 200" do
    get superpowers_path(date: 7.days.ago.to_date.to_s)
    assert_response :success
  end

  test "GET /superpowers with garbage date param returns 200 (falls back to today)" do
    get superpowers_path(date: "not-a-date")
    assert_response :success
  end

  test "GET /superpowers with empty date param returns 200 (falls back to today)" do
    get superpowers_path(date: "")
    assert_response :success
  end

  # Regression: "Submit" used to be a bare link straight to /tracking with no
  # review step at all, unlike /symptoms' pre-submit summary modal.
  test "GET /superpowers renders the pre-submit review modal, not a bare submit link" do
    get superpowers_path
    assert_response :success
    assert_select "[data-controller='superpowers-submit-modal']"
    assert_select "[data-superpowers-submit-modal-target='modal']"
    assert_select "button[data-action='click->superpowers-submit-modal#open']", text: "Submit"
    # tracking_saved=1 is what triggers the post-save prediction modal on
    # /tracking -- see tracking_controller_test.rb.
    assert_select "a[href='#{tracking_index_path(tracking_saved: 1)}']", text: "Submit tracking"
  end

  # Regression: see the matching test in symptoms_controller_test.rb --
  # [data-selected] was never set here either, on the shared date picker.
  test "GET /superpowers marks today as the selected day in the date picker" do
    get superpowers_path
    assert_response :success
    assert_select "a[data-selected='true']", text: Time.zone.today.strftime("%-d %B")
  end
end
