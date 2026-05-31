# rubocop:disable Rails/I18nLocaleTexts
module Admin
  class CycleDayContentsController < Admin::BaseController
    before_action :set_content, only: [:edit, :update, :destroy]

    def index
      locale = params[:locale].presence || "en"
      @contents = CycleDayContent.where(locale: locale).order(:cycle_day, :card_type)
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

      locale = params[:locale].presence || "en"
      imported = 0
      errors = []

      CSV.foreach(file.path, headers: true, liberal_parsing: true) do |row|
        day = row["Day"].to_i
        next unless day.between?(1, 35)

        # Detect column naming (English vs German)
        has_en = row.key?("Superpower Short Text (EN)")
        row.key?("Super Power Kurztext")

        col = ->(en, de) { has_en ? row[en] : row[de] }

        mappings = if has_en
          [
            {type: "superpower", short: col.call("Superpower Short Text (EN)", nil), long: col.call("Superpower Long Text (EN)", nil)},
            {type: "watch_out_for", short: col.call("Watch Out For (EN)", nil), long: col.call("Watch Out For - Expandable Text (EN)", nil)},
            {type: "mood", short: col.call("Mood (use our emojis) (EN)", nil), long: col.call("Mood (use our emojis) (EN)", nil)},
            {type: "sport", short: col.call("Sport (EN)", nil), long: col.call("Sport - Expandable Text (EN)", nil)},
            {type: "nutrition", short: col.call("Nutrition (EN)", nil), long: col.call("Nutrition - Expandable Text (EN)", nil)},
            {type: "fertility", short: col.call("Fertility (EN)", nil), long: col.call("Fertility - Expandable Text (EN)", nil).presence || col.call("Fertility (EN)", nil)}
          ]
        else
          [
            {type: "superpower", short: col.call(nil, "Super Power Kurztext"), long: col.call(nil, "Super Power Lang Text")},
            {type: "watch_out_for", short: col.call(nil, "Achte auf"), long: col.call(nil, "AA Klapptext")},
            {type: "mood", short: col.call(nil, "Stimmung (bitte unsere Emojis dafür benutzen)"), long: col.call(nil, "Stimmung (bitte unsere Emojis dafür benutzen)")},
            {type: "sport", short: col.call(nil, "Sport"), long: col.call(nil, "Sport Klapptext")},
            {type: "nutrition", short: col.call(nil, "Ernährung"), long: col.call(nil, "Ernährung Klapptext")},
            {type: "fertility", short: col.call(nil, "Fruchtbarkeit"), long: col.call(nil, "Fruchtbarkeit Klapptext").presence || col.call(nil, "Fruchtbarkeit")}
          ]
        end

        mappings.each do |m|
          next if m[:short].blank?

          rec = CycleDayContent.find_or_initialize_by(cycle_day: day, card_type: m[:type], locale: locale)
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
      params.expect(cycle_day_content: [:cycle_day, :card_type, :locale, :short_text, :long_text, food_items: {}])
    end
  end
end
# rubocop:enable Rails/I18nLocaleTexts
