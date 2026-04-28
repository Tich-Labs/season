class Admin::CyclePhaseContentsController < Admin::BaseController
  before_action :set_cycle_phase_content, only: [:edit, :update]

  def index
    @contents = CyclePhaseContent.order(:phase, :locale)
  end

  def edit
  end

  def update
    if @content.update(cycle_phase_content_params)
      redirect_to admin_cycle_phase_contents_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_cycle_phase_content
    @content = CyclePhaseContent.find(params[:id])
  end

  def cycle_phase_content_params
    params.expect(
      cycle_phase_content: [
        :season_name,
        :superpower_text,
        :mood_text,
        :take_care_text,
        :sport_text,
        :nutrition_text
      ]
    )[:cycle_phase_content]
  end
end
