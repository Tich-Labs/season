class Admin::CyclePhaseContentsController < Admin::BaseController
  before_action :set_cycle_phase_content, only: [:edit, :update, :destroy]

  def index
    @contents = CyclePhaseContent.order(:phase, :locale)
  end

  def new
    @content = CyclePhaseContent.new
  end

  def edit
  end

  def create
    @content = CyclePhaseContent.new(cycle_phase_content_params)

    if @content.save
      redirect_to admin_cycle_phase_contents_path, notice: t(".created")
    else
      flash.now[:alert] = @content.errors.full_messages.to_sentence
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @content.update(cycle_phase_content_params)
      redirect_to admin_cycle_phase_contents_path, notice: t(".updated")
    else
      flash.now[:alert] = @content.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @content.destroy
    redirect_to admin_cycle_phase_contents_path, notice: t(".destroyed")
  end

  private

  def set_cycle_phase_content
    @content = CyclePhaseContent.find(params[:id])
  end

  def cycle_phase_content_params
    params.expect(
      cycle_phase_content: [:phase,
        :locale,
        :season_name,
        :superpower_text,
        :mood_text,
        :take_care_text,
        :sport_text,
        :nutrition_text]
    )
  end
end
