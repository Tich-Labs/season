require "rails_helper"

RSpec.describe "Tester tour", type: :request do
  let(:user) { create(:user, :onboarded) }

  before { post session_path, params: {email: user.email, password: "password123"} }

  describe "GET /welcome_tour" do
    it "renders the tour" do
      get tester_tour_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Hello, dear tester")
    end

    it "renders all 6 slides" do
      get tester_tour_path
      expect(response.body).to include("Hello, dear tester")
      expect(response.body).to include("The Calendar")
      expect(response.body).to include("Track Your Day")
      expect(response.body).to include("Schedule an Appointment")
      expect(response.body).to include("Forecast")
      expect(response.body).to include("An Explanation of Menstrual Cycle Colors")
    end
  end

  describe "POST /welcome_tour/complete" do
    it "marks the tour seen and redirects to the calendar" do
      expect(user.tester_tour_seen_at).to be_nil

      post complete_tester_tour_path
      expect(response).to redirect_to(calendar_path)
      expect(user.reload.tester_tour_seen_at).to be_present
    end
  end

  describe "onboarding finish redirect" do
    it "sends a first-time user to the tour, not straight to the calendar" do
      get onboarding_finish_path
      expect(response.body).to include(tester_tour_path.to_json)
    end

    it "sends a user who already saw the tour straight to the calendar" do
      user.update!(tester_tour_seen_at: Time.current)
      get onboarding_finish_path
      expect(response.body).to include(calendar_path.to_json)
    end

    it "points the Refresh header at the tour for a first-time user" do
      get onboarding_finish_path
      expect(response.headers["Refresh"]).to eq("1.5;url=#{tester_tour_path}")
    end

    it "points the Refresh header at the calendar once the tour is seen" do
      user.update!(tester_tour_seen_at: Time.current)
      get onboarding_finish_path
      expect(response.headers["Refresh"]).to eq("1.5;url=#{calendar_path}")
    end
  end
end
