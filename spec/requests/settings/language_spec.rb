require "rails_helper"

RSpec.describe "Settings::Language", type: :request do
  # This app's current_user is its own session[:user_id]-based
  # Authentication concern, entirely separate from Devise's Warden
  # session — Devise::Test's `sign_in` sets the Warden session, which
  # current_user never reads, so this silently redirected to the login
  # page instead of reaching the settings controller at all.
  let(:user) { create(:user, :onboarded) }

  before { post session_path, params: {email: user.email, password: "password123"} }

  describe "GET show" do
    it "renders the language settings page" do
      get settings_language_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Deutsch")
    end
  end

  describe "PATCH update" do
    it "updates the user's language and redirects to the settings hub" do
      patch settings_language_path, params: {user: {language: "de"}}
      # Not settings_language_path — the controller deliberately redirects
      # back to the settings hub (with a flash notice) on both success and
      # failure here, the same pattern the invalid-language branch uses.
      expect(response).to redirect_to(edit_settings_path)
      user.reload
      expect(user.language).to eq("de")
    end
  end
end
