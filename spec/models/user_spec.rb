require "rails_helper"

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  describe "Devise authentication" do
    it { expect(user).to be_valid }
    it { expect(user).to be_active_for_authentication }
    it { expect(user.valid_password?(user.password)).to be true }
    it { expect(user.valid_password?("wrongpassword")).to be false }
  end
end
