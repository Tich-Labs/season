require "rails_helper"

RSpec.describe "Registrations", type: :request do
  describe "GET new" do
    before { get new_registration_path }

    it { expect(response).to have_http_status(:success) }
  end

  describe "POST create" do
    let(:params) do
      {
        # Flat, top-level params — RegistrationsController#user_params is
        # `params.permit(:email, :password, :password_confirmation,
        # :name)`, not nested under :user. Posting `user: {...}` (as this
        # test used to) meant every one of those came through blank,
        # tripping "Email can't be blank" and rendering :new — which
        # incidentally also meant the missing `terms_accepted` below was
        # never actually exercised as a check by this test either.
        terms_accepted: "1",
        email: "new#{Time.now.to_i}@test.com",
        password: "password123",
        password_confirmation: "password123"
      }
    end

    it "creates account" do
      expect {
        post registration_path, params: params
      }.to change(User, :count).by(1)
      # Not onboarding_path(1) — signup redirects to the "check your
      # inbox" page first (Devise :confirmable); onboarding only starts
      # after confirming via the emailed link.
      expect(response).to redirect_to(check_email_registration_path)
    end
  end
end
