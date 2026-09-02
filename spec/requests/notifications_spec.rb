require "rails_helper"

RSpec.describe "Notifications", type: :request do
  # This app's current_user is its own session[:user_id]-based
  # Authentication concern, entirely separate from Devise's Warden
  # session — Devise::Test's `sign_in` sets the Warden session, which
  # current_user never reads, so every request here silently redirected
  # to the login page instead of reaching NotificationsController at all.
  let(:user) { create(:user, :onboarded) }

  before { post session_path, params: {email: user.email, password: "password123"} }

  describe "GET /notifications" do
    it "returns http success" do
      get notifications_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /notifications/:id" do
    # None of these three originally hit the action their name claimed —
    # "/notifications/show", "/notifications/mark_read", and
    # "/notifications/delete" aren't real routes; resources routing
    # matched all three to GET /notifications/:id (the show action) with
    # the literal string "show"/"mark_read"/"delete" as the :id, which
    # doesn't correspond to any real notification. mark_read is a PATCH
    # to /notifications/:id/mark_read, and delete is a DELETE to
    # /notifications/:id — neither is reachable via a bare GET at all.
    let(:notification) { create(:notification, user: user) }

    it "returns http success for the user's own notification" do
      get notification_path(notification)
      expect(response).to have_http_status(:success)
    end

    it "marks it as read as a side effect of viewing it" do
      expect { get notification_path(notification) }
        .to change { notification.reload.read? }.from(false).to(true)
    end
  end

  describe "PATCH /notifications/:id/mark_read" do
    let(:notification) { create(:notification, user: user) }

    it "marks the notification read and redirects" do
      patch mark_read_notification_path(notification)
      expect(response).to redirect_to(notifications_path)
      expect(notification.reload.read?).to be true
    end
  end

  describe "DELETE /notifications/:id" do
    let!(:notification) { create(:notification, user: user) }

    it "deletes the notification" do
      expect { delete notification_path(notification) }
        .to change(Notification, :count).by(-1)
    end
  end
end
