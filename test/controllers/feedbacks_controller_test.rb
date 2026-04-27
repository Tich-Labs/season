require "test_helper"

# M7 — In-app Feedback
class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @alice = users(:alice)
    sign_in_as(@alice)
  end

  test "POST /feedbacks creates a feedback record" do
    assert_difference("Feedback.count", 1) do
      post feedbacks_path, params: {feedback: {type: "feedback", message: "Love the app!"}}
    end
  end

  test "POST /feedbacks requires authentication" do
    delete session_path
    post feedbacks_path, params: {feedback: {type: "feedback", message: "Test"}}
    assert_redirected_to new_session_path
  end

  test "POST /feedbacks with blank message renders error" do
    post feedbacks_path, params: {feedback: {type: "feedback", message: ""}}
    assert_response :unprocessable_entity
  end

  test "POST /feedbacks accepts bug_report type" do
    assert_difference("Feedback.count", 1) do
      post feedbacks_path, params: {feedback: {type: "bug_report", message: "Found a bug"}}
    end
    assert_equal "bug_report", Feedback.last.type
  end

  test "POST /feedbacks accepts support type" do
    assert_difference("Feedback.count", 1) do
      post feedbacks_path, params: {feedback: {type: "support", message: "Need help"}}
    end
  end
end
