class InformationsController < ApplicationController
  include Authentication

  PHASES = %w[menstrual follicular ovulation luteal].freeze

  def index
    @phases = PHASES.map do |phase|
      content = CyclePhaseContent.for(phase, I18n.locale.to_s)
      meta = phase_meta(phase)
      {phase: phase, content: content, meta: meta}
    end
  end

  def show
    phase = params[:phase]
    redirect_to informations_path unless PHASES.include?(phase)

    @phase = phase
    @content = CyclePhaseContent.for(phase, I18n.locale.to_s)
    @meta = phase_meta(phase)
  end

  private

  def phase_meta(phase)
    {
      "menstrual" => {
        season: "Winter", colour: "#933a35", text_colour: "#FFFFFF",
        days: "Day 1–6", hormone_note: "Estrogen is produced slowly",
        emoji: "❄️"
      },
      "follicular" => {
        season: "Spring", colour: "#899884", text_colour: "#FFFFFF",
        days: "Day 7–14", hormone_note: "Estrogen and testosterone levels rise",
        emoji: "🌱"
      },
      "ovulation" => {
        season: "Summer", colour: "#50705b", text_colour: "#FFFFFF",
        days: "Day 15–21", hormone_note: "Progesterone levels rise",
        emoji: "☀️"
      },
      "luteal" => {
        season: "Autumn", colour: "#D18D83", text_colour: "#FFFFFF",
        days: "Day 22–28", hormone_note: "Decline in estrogen and progesterone levels",
        emoji: "🍂"
      }
    }[phase]
  end
end
