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

  test "marks a registered iOS tester invited via the public link fallback" do
    called = false
    with_env("TESTFLIGHT_PUBLIC_LINK", nil) do
      stub_class_method(AppStoreConnectService, :configured?, -> { true }) do
        stub_class_method(AppStoreConnectService, :invite, ->(_tester) { called = true }) do
          InviteBetaTesterJob.perform_now(@tester.id)
        end
      end
    end

    assert_not called
    assert_equal "invited", @tester.reload.status
  end

  test "invites a registered Android tester and marks it invited" do
    @tester.update!(platform: "android")

    called = false
    with_env("GOOGLE_PLAY_GROUP_URL", nil) do
      with_env("GOOGLE_PLAY_OPEN_TESTING_URL", nil) do
        stub_class_method(GooglePlayClosedTestingService, :configured?, -> { true }) do
          stub_class_method(GooglePlayClosedTestingService, :invite, ->(_tester) { called = true }) do
            InviteBetaTesterJob.perform_now(@tester.id)
          end
        end
      end
    end

    assert called
    assert_equal "invited", @tester.reload.status
  end

  test "marks iOS testers invited without App Store Connect via the public link" do
    called = false
    with_env("TESTFLIGHT_PUBLIC_LINK", nil) do
      stub_class_method(AppStoreConnectService, :configured?, -> { false }) do
        stub_class_method(AppStoreConnectService, :invite, ->(_tester) { called = true }) do
          InviteBetaTesterJob.perform_now(@tester.id)
        end
      end
    end

    assert_not called
    assert_equal "invited", @tester.reload.status
  end

  test "does nothing for Android when Google Play is not configured" do
    @tester.update!(platform: "android")

    called = false
    with_env("GOOGLE_PLAY_GROUP_URL", nil) do
      with_env("GOOGLE_PLAY_OPEN_TESTING_URL", nil) do
        stub_class_method(GooglePlayClosedTestingService, :configured?, -> { false }) do
          stub_class_method(GooglePlayClosedTestingService, :invite, ->(_tester) { called = true }) do
            InviteBetaTesterJob.perform_now(@tester.id)
          end
        end
      end
    end

    assert_not called
    assert_equal "registered", @tester.reload.status
  end

  test "ignores web testers" do
    @tester.update!(platform: "web")

    InviteBetaTesterJob.perform_now(@tester.id)

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

  test "skips the API and marks invited when the TestFlight public link is set" do
    called = false
    with_env("TESTFLIGHT_PUBLIC_LINK", "https://testflight.apple.com/join/ABC") do
      stub_class_method(AppStoreConnectService, :configured?, -> { true }) do
        stub_class_method(AppStoreConnectService, :invite, ->(_tester) { called = true }) do
          InviteBetaTesterJob.perform_now(@tester.id)
        end
      end
    end

    assert_not called
    assert_equal "invited", @tester.reload.status
  end

  test "skips the API and marks invited when the Play open-testing link is set" do
    @tester.update!(platform: "android")

    called = false
    with_env("GOOGLE_PLAY_OPEN_TESTING_URL", "https://play.google.com/apps/testing/com.onrender.seasonv2.rubynative") do
      stub_class_method(GooglePlayClosedTestingService, :configured?, -> { true }) do
        stub_class_method(GooglePlayClosedTestingService, :invite, ->(_tester) { called = true }) do
          InviteBetaTesterJob.perform_now(@tester.id)
        end
      end
    end

    assert_not called
    assert_equal "invited", @tester.reload.status
  end

  test "skips the API and marks invited when the Google Group link is set" do
    @tester.update!(platform: "android")

    called = false
    with_env("GOOGLE_PLAY_GROUP_URL", "https://groups.google.com/g/season2_beta_tester/") do
      stub_class_method(GooglePlayClosedTestingService, :configured?, -> { true }) do
        stub_class_method(GooglePlayClosedTestingService, :invite, ->(_tester) { called = true }) do
          InviteBetaTesterJob.perform_now(@tester.id)
        end
      end
    end

    assert_not called
    assert_equal "invited", @tester.reload.status
  end
end
