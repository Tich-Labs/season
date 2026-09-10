# First-run beta-tester welcome tour — Figma "Onboarding" row on the M7
# canvas. Six slides matching Figma exactly: Introduction, The Calendar,
# Track Your Day, Schedule an Appointment, Forecast, and an explanation of
# the menstrual-cycle colours. Screenshots are captured from the running
# English app. Shown once, right after the signup onboarding flow finishes
# (see OnboardingController#finish's redirect).
class TesterTourController < ApplicationController
  layout "launch"

  TOTAL_SLIDES = 6

  def show
  end

  def complete
    current_user.update!(tester_tour_seen_at: Time.current)
    redirect_to calendar_path
  end
end
