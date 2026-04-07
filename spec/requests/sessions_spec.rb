require "rails_helper"

RSpec.describe "Sessions", type: :request do
  describe "GET new" do
    before { get new_session_path }

    it { expect(response).to have_http_status(:success) }
  end
end
