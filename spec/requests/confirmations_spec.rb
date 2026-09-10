require "rails_helper"

RSpec.describe "Confirmations", type: :request do
  describe "GET /users/confirmation/new" do
    it "renders under the launch layout without in-app chrome" do
      get new_user_confirmation_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Resend")
      expect(response.body).not_to include("Open quick actions")
      expect(response.body).not_to include("Back to calendar")
    end

    context "when a signed-in user lands on it" do
      it "still renders without the calendar-home / quick-actions FABs" do
        user = create(:user, :onboarded)
        post session_path, params: {email: user.email, password: "password123"}

        get new_user_confirmation_path
        expect(response).to have_http_status(:success)
        expect(response.body).not_to include("Open quick actions")
        expect(response.body).not_to include("Back to calendar")
      end
    end
  end
end
