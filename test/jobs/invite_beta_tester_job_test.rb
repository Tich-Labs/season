# frozen_string_literal: true

require "test_helper"

class InviteBetaTesterJobTest < ActiveJob::TestCase
  setup do
    @tester = BetaTester.create!(
      name: "Alice Smith",
      email: "alice@example.com",
      platform: "ios",
      beta_consent: true
    )
  end

  test "invites a registered iOS tester and marks it invited" do
    called = false
    stub_class_method(AppStoreConnectService, :configured?, -> { true }) do
      stub_class_method(AppStoreConnectService, :invite, ->(_tester) { called = true }) do
        InviteBetaTesterJob.perform_now(@tester.id)
      end
    end

    assert called
    assert_equal "invited", @tester.reload.status
  end

  test "does nothing when App Store Connect is not configured" do
    called = false
    stub_class_method(AppStoreConnectService, :configured?, -> { false }) do
      stub_class_method(AppStoreConnectService, :invite, ->(_tester) { called = true }) do
        InviteBetaTesterJob.perform_now(@tester.id)
      end
    end

    assert_not called
    assert_equal "registered", @tester.reload.status
  end

  test "ignores non-iOS testers" do
    @tester.update!(platform: "android")

    called = false
    stub_class_method(AppStoreConnectService, :configured?, -> { true }) do
      stub_class_method(AppStoreConnectService, :invite, ->(_tester) { called = true }) do
        InviteBetaTesterJob.perform_now(@tester.id)
      end
    end

    assert_not called
    assert_equal "registered", @tester.reload.status
  end

  test "does not re-invite a tester that is already invited" do
    @tester.update!(status: "invited")

    called = false
    stub_class_method(AppStoreConnectService, :configured?, -> { true }) do
      stub_class_method(AppStoreConnectService, :invite, ->(_tester) { called = true }) do
        InviteBetaTesterJob.perform_now(@tester.id)
      end
    end

    assert_not called
  end
end
