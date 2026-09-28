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
    assert_includes response.body, @late.public_id
    assert_not_includes response.body, @early.public_id
  end

  test "ignores an invalid date" do
    get admin_users_path(signed_up_from: "not-a-date")
    assert_response :success
    assert_includes response.body, @early.public_id
  end

  test "filters to secret testers" do
    get admin_users_path(q: {secret_tester_eq: true})
    assert_includes response.body, @late.public_id
    assert_not_includes response.body, @early.public_id
  end

  test "CSV export respects the date filter" do
    get admin_users_path(format: :csv, signed_up_to: "2026-09-19")
    assert_includes response.body, @early.public_id
    assert_not_includes response.body, @late.public_id
  end

  test "users list and detail identify people by User ID only, never name or email" do
    get admin_users_path
    assert_includes response.body, @early.public_id
    assert_no_match(/Early Bird|early@example\.com/, response.body)

    get admin_user_path(@early)
    assert_response :success
    assert_includes response.body, @early.public_id
    assert_no_match(/Early Bird|early@example\.com/, response.body)

    get admin_users_path(format: :csv)
    assert_no_match(/Early Bird|early@example\.com/, response.body)
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
