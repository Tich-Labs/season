require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = User.create!(
      email: "usersadmin@example.com", name: "Users Admin", password: "password123", password_confirmation: "password123",
      admin: true
    ).tap(&:confirm)
    @early = create_user("early@example.com", "Early Bird", Time.zone.parse("2026-09-10 12:00"))
    @late = create_user("late@example.com", "Late Comer", Time.zone.parse("2026-09-25 23:30"), secret_tester: true)
    sign_in_as(@admin)
  end

  test "filters by signed-up date range, inclusive of the end day" do
    get admin_users_path(signed_up_from: "2026-09-20", signed_up_to: "2026-09-25")
    assert_response :success
    assert_match(/Late Comer/, response.body)
    assert_no_match(/Early Bird/, response.body)
  end

  test "ignores an invalid date" do
    get admin_users_path(signed_up_from: "not-a-date")
    assert_response :success
    assert_match(/Early Bird/, response.body)
  end

  test "filters to secret testers" do
    get admin_users_path(q: {secret_tester_eq: true})
    assert_match(/Late Comer/, response.body)
    assert_no_match(/Early Bird/, response.body)
  end

  test "CSV export respects the date filter" do
    get admin_users_path(format: :csv, signed_up_to: "2026-09-19")
    assert_match(/early@example.com/, response.body)
    assert_no_match(/late@example.com/, response.body)
  end

  test "tags and untags a secret tester" do
    patch admin_user_path(@early, user: {secret_tester: true})
    assert @early.reload.secret_tester?

    patch admin_user_path(@early, user: {secret_tester: false})
    assert_not @early.reload.secret_tester?
  end

  private

  def create_user(email, name, created_at, **attrs)
    User.create!(email: email, name: name, password: "password123", password_confirmation: "password123", **attrs)
      .tap { |u| u.update_columns(created_at: created_at) }
  end
end
