require "rails_helper"

RSpec.describe "Registrations", type: :request do
  describe "GET new" do
    before { get new_registration_path }

    it { expect(response).to have_http_status(:success) }
  end

  describe "POST create" do
    let(:params) do
      {
        user: {
          email: "new#{Time.now.to_i}@test.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    it "creates account" do
      expect {
        post registration_path, params: params
      }.to change(User, :count).by(1)
      expect(response).to redirect_to(onboarding_path(1))
    end
  end
end
