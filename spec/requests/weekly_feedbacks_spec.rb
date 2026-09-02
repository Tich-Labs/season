require "rails_helper"

# Covers the full-page hub + wizard that replaced the old bottom-sheet
# modal (which had no reachable trigger anywhere in the UI — see the
# burger menu "Feedback" link, now pointed at weekly_feedback_path).
RSpec.describe "Weekly feedback", type: :request do
  let(:user) { create(:user, :onboarded, created_at: 8.days.ago) }
  let!(:mc_question) do
    WeeklyFeedbackQuestion.create!(week_number: user.current_feedback_week, question_type: "multiple_choice",
      question_text: "First impression?", options: %w[Good Bad Neutral], position: 1, active: true)
  end
  let!(:text_question) do
    WeeklyFeedbackQuestion.create!(week_number: user.current_feedback_week, question_type: "text_only",
      question_text: "Anything else?", position: 2, active: true)
  end

  before { post session_path, params: {email: user.email, password: "password123"} }

  describe "GET /weekly_feedback" do
    it "renders the hub with the current week highlighted" do
      get weekly_feedback_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include("Feedback week #{user.current_feedback_week}")
    end
  end

  describe "GET /weekly_feedback/:week" do
    it "renders the wizard for the current week" do
      get weekly_feedback_week_path(user.current_feedback_week)
      expect(response).to have_http_status(:success)
      expect(response.body).to include("First impression?")
    end

    it "redirects away from a locked future week" do
      get weekly_feedback_week_path(user.current_feedback_week + 2)
      expect(response).to redirect_to(weekly_feedback_path)
    end

    it "shows the already-completed state for a past, submitted week" do
      past_question = WeeklyFeedbackQuestion.create!(week_number: user.current_feedback_week - 1,
        question_type: "text_only", question_text: "Past week question", position: 1, active: true)
      user.weekly_feedback_responses.create!(weekly_feedback_question: past_question,
        week_number: user.current_feedback_week - 1, submission_batch_id: SecureRandom.uuid,
        response_text: "answered")

      get weekly_feedback_week_path(user.current_feedback_week - 1)
      expect(response).to have_http_status(:success)
      expect(response.body).not_to include("Past week question")
    end
  end

  describe "POST /weekly_feedback/submit" do
    it "records answers for the current week's questions" do
      expect {
        post submit_weekly_feedback_path, params: {
          answers: {mc_question.id.to_s => "Good", text_question.id.to_s => "Loving it"}
        }, as: :json
      }.to change(WeeklyFeedbackResponse, :count).by(2)

      expect(response).to have_http_status(:success)
      expect(user.weekly_feedback_responses.find_by(weekly_feedback_question: mc_question).selected_option).to eq("Good")
    end
  end
end
