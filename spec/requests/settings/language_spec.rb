require "rails_helper"

RSpec.describe "Settings::Language", type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, :onboarded) }

  before { sign_in user }

  describe "GET show" do
    it "renders the language settings page" do
      get settings_language_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Deutsch")
    end
  end

  describe "PATCH update" do
    it "updates the user's language and redirects" do
      patch settings_language_path, params: {user: {language: "de"}}
      expect(response).to redirect_to(settings_language_path)
      user.reload
      expect(user.language).to eq("de")
    end
  end
end
