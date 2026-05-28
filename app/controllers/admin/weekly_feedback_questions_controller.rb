class Admin::WeeklyFeedbackQuestionsController < Admin::BaseController
  before_action :set_question, only: [:edit, :update, :destroy]

  def index
    @weeks = (1..8).to_a
    @questions_by_week = WeeklyFeedbackQuestion.order(:week_number, :position)
      .group_by(&:week_number)
  end

  def new
    @question = WeeklyFeedbackQuestion.new(active: true)
  end

  def edit
  end

  def create
    @question = WeeklyFeedbackQuestion.new(question_params)

    if @question.save
      redirect_to admin_weekly_feedback_questions_path, notice: t(".created")
    else
      flash.now[:alert] = @question.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @question.update(question_params)
      redirect_to admin_weekly_feedback_questions_path, notice: t(".updated")
    else
      flash.now[:alert] = @question.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @question.destroy
    redirect_to admin_weekly_feedback_questions_path, notice: t(".destroyed")
  end

  private

  def set_question
    @question = WeeklyFeedbackQuestion.find(params[:id])
  end

  def question_params
    raw = params.expect(weekly_feedback_question: [:week_number, :question_type, :question_text, :options_text, :position, :active])
    raw[:options] = raw.delete(:options_text).to_s.split("\n").map(&:strip).compact_blank
    raw
  end
end
