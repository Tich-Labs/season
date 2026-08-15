require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    sign_in_as(@alice)
  end

  test "GET /notifications returns 200" do
    get notifications_path
    assert_response :success
  end

  test "GET /notifications requires authentication" do
    delete session_path
    get notifications_path
    assert_redirected_to new_session_path
  end

  test "GET /notifications/:id returns 200 and marks it read" do
    notification = @alice.notifications.create!(title: "Reminder", notification_type: "reminder")
    get notification_path(notification)
    assert_response :success
    assert notification.reload.read?
  end

  test "PATCH /notifications/:id/mark_read marks it read" do
    notification = @alice.notifications.create!(title: "Reminder", notification_type: "reminder")
    patch mark_read_notification_path(notification)
    assert_redirected_to notifications_path
    assert notification.reload.read?
  end

  test "DELETE /notifications/:id removes it" do
    notification = @alice.notifications.create!(title: "Reminder", notification_type: "reminder")
    assert_difference("Notification.count", -1) do
      delete notification_path(notification)
    end
  end

  test "cannot view another user's notification" do
    bob_notification = users(:bob).notifications.create!(title: "Bob's reminder", notification_type: "reminder")
    get notification_path(bob_notification)
    assert_response :not_found
  end

  test "cannot mark another user's notification as read" do
    bob_notification = users(:bob).notifications.create!(title: "Bob's reminder", notification_type: "reminder")
    patch mark_read_notification_path(bob_notification)
    assert_response :not_found
    assert_not bob_notification.reload.read?
  end

  test "cannot delete another user's notification" do
    bob_notification = users(:bob).notifications.create!(title: "Bob's reminder", notification_type: "reminder")
    assert_no_difference("Notification.count") do
      delete notification_path(bob_notification)
    end
    assert_response :not_found
  end
end
