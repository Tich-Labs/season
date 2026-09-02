# First-run beta-tester welcome tour — Figma "Onboarding" row on the M7
# canvas (nodes 12178:8446, 8463, 8541, 8570, 8629, and two more still
# pending: 8600 "Probleme melden" / 8496 closing "Kalender overview", not
# yet pulled — see docs/M4.md). Shown once, right after the signup
# onboarding flow finishes (see OnboardingController#finish's redirect).
class TesterTourController < ApplicationController
  layout "launch"

  # Slides 6 ("Probleme melden") and 7 (closing "Kalender overview") are
  # intentionally left out until their Figma content is pulled — better to
  # ship 5 accurate slides than fabricate copy for the other two.
  TOTAL_SLIDES = 5

  def show
  end

  def complete
    current_user.update!(tester_tour_seen_at: Time.current)
    redirect_to calendar_path
  end
end
