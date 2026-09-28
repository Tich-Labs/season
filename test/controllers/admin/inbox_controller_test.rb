require "test_helper"

class Admin::InboxControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = User.create!(
      email: "inboxadmin@example.com", name: "Inbox Admin", password: "password123", password_confirmation: "password123",
      admin: true
    ).tap(&:confirm)
    Feedback.delete_all
    Feedback.create!(user: @admin, type: "bug_report", message: "Old archived bug", active: false)
    Feedback.create!(user: @admin, type: "bug_report", message: "Fresh open bug")
  end

  test "bugs inbox hides archived reports" do
    sign_in_as(@admin)
    get admin_inbox_bugs_path
    assert_response :success
    assert_match(/Fresh open bug/, response.body)
    assert_no_match(/Old archived bug/, response.body)
  end

  test "CSV export excludes archived reports" do
    sign_in_as(@admin)
    get admin_inbox_export_csv_path(filter: "bugs", format: :csv)
    assert_response :success
    assert_match(/Fresh open bug/, response.body)
    assert_no_match(/Old archived bug/, response.body)
  end
end
