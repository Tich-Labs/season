class InformationsController < ApplicationController
  PHASES = CycleEntry::PHASES

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

  HORMONE_NOTES = {
    "menstrual" => {note: "Estrogen is produced slowly", emoji: "❄️"},
    "follicular" => {note: "Estrogen and testosterone levels rise", emoji: "🌱"},
    "ovulation" => {note: "Progesterone levels rise", emoji: "☀️"},
    "luteal" => {note: "Decline in estrogen and progesterone levels", emoji: "🍂"}
  }.freeze

  private

  def phase_meta(phase)
    CycleCalculatorService::PHASE_META[phase].merge(HORMONE_NOTES[phase] || {})
  end
end
