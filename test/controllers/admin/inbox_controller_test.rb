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

  test "archive button archives a message and records who and when" do
    sign_in_as(@admin)
    bug = Feedback.find_by!(message: "Fresh open bug")
    patch admin_inbox_archive_path(bug)
    assert_redirected_to admin_inbox_path
    bug.reload
    assert bug.archived?
    assert_equal @admin, bug.archived_by
    assert_not_nil bug.archived_at
  end

  test "archived view lists archived messages and restore brings one back" do
    sign_in_as(@admin)
    get admin_inbox_archived_path
    assert_response :success
    assert_match(/Old archived bug/, response.body)
    assert_no_match(/Fresh open bug/, response.body)

    old = Feedback.find_by!(message: "Old archived bug")
    patch admin_inbox_unarchive_path(old)
    old.reload
    assert_not old.archived?
    assert_nil old.archived_by
  end

  test "bulk archive only touches the current view's messages created before the date" do
    sign_in_as(@admin)
    early_bug = Feedback.create!(user: @admin, type: "bug_report", message: "Early bug")
    early_support = Feedback.create!(user: @admin, type: "support", message: "Early support")
    [early_bug, early_support].each { |f| f.update_columns(created_at: Time.zone.parse("2026-09-10 12:00")) }

    post admin_inbox_archive_before_path, params: {filter: "bugs", before: "2026-09-20"}
    assert early_bug.reload.archived?
    assert_equal @admin, early_bug.archived_by
    assert_not early_support.reload.archived?
    assert_not Feedback.find_by!(message: "Fresh open bug").archived?
  end

  test "bulk archive rejects a missing date" do
    sign_in_as(@admin)
    post admin_inbox_archive_before_path, params: {filter: "bugs", before: ""}
    assert_equal "Pick a valid date to archive before.", flash[:alert]
  end
end
