module Admin
  class CycleDayContentsController < Admin::BaseController
    before_action :set_content, only: [:edit, :update, :destroy]

    def index
      @contents = CycleDayContent.order(:cycle_day, :card_type)
    end

    def new
      @content = CycleDayContent.new
    end

    def edit
    end

    def create
      @content = CycleDayContent.new(content_params)
      if @content.save
        redirect_to admin_cycle_day_contents_path, notice: "Day #{@content.cycle_day} #{@content.card_type} created."
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @content.update(content_params)
        redirect_to admin_cycle_day_contents_path, notice: "Day #{@content.cycle_day} #{@content.card_type} updated."
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @content.destroy
      redirect_to admin_cycle_day_contents_path, notice: "Deleted."
    end

    private

    def set_content
      @content = CycleDayContent.find(params[:id])
    end

    def content_params
      params.expect(cycle_day_content: [:cycle_day, :card_type, :short_text, :long_text, food_items: {}])
    end
  end
end
