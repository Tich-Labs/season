# rubocop:disable Rails/I18nLocaleTexts
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

    def import_csv
      require "csv"

      file = params[:csv_file]
      unless file
        redirect_to admin_cycle_day_contents_path, alert: "Please select a CSV file."
        return
      end

      imported = 0
      errors = []

      CSV.foreach(file.path, headers: true, liberal_parsing: true) do |row|
        day = row["Day"].to_i
        next unless day.between?(1, 35)

        mappings = [
          {type: "superpower", short: row["Superpower Short Text (EN)"], long: row["Superpower Long Text (EN)"]},
          {type: "watch_out_for", short: row["Watch Out For (EN)"], long: row["Watch Out For - Expandable Text (EN)"]},
          {type: "mood", short: row["Mood (use our emojis) (EN)"], long: row["Mood (use our emojis) (EN)"]},
          {type: "sport", short: row["Sport (EN)"], long: row["Sport - Expandable Text (EN)"]},
          {type: "nutrition", short: row["Nutrition (EN)"], long: row["Nutrition - Expandable Text (EN)"]},
          {type: "fertility", short: row["Fertility (EN)"], long: row["Fertility - Expandable Text (EN)"].presence || row["Fertility (EN)"]}
        ]

        mappings.each do |m|
          next if m[:short].blank?

          rec = CycleDayContent.find_or_initialize_by(cycle_day: day, card_type: m[:type])
          rec.update!(short_text: m[:short].strip, long_text: m[:long]&.strip || m[:short].strip)
          imported += 1
        end
      rescue => e
        errors << "Row #{$.}: #{e.message}"
      end

      notice = "Imported #{imported} records."
      notice += " Errors: #{errors.join("; ")}" if errors.any?
      redirect_to admin_cycle_day_contents_path, notice: notice
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
# rubocop:enable Rails/I18nLocaleTexts
