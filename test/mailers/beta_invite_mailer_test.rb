# frozen_string_literal: true

require "test_helper"

class BetaInviteMailerTest < ActionMailer::TestCase
  setup do
    @tester = BetaTester.create!(
      name: "Alice Smith",
      email: "alice@example.com",
      platform: "android",
      beta_consent: true
    )
  end

  test "android_group_links delivers to the tester's email" do
    mail = BetaInviteMailer.android_group_links(@tester)
    assert_equal [@tester.email], mail.to
    assert_match "Android", mail.subject
  end

  test "android_group_links includes the group and Play links when set" do
    with_env("GOOGLE_PLAY_GROUP_URL", "https://groups.google.com/g/season2_beta_tester/") do
      with_env("GOOGLE_PLAY_OPEN_TESTING_URL", "https://play.google.com/apps/testing/com.onrender.seasonv2.rubynative") do
        mail = BetaInviteMailer.android_group_links(@tester)
        assert_match "season2_beta_tester", mail.body.encoded
        assert_match "apps/testing", mail.body.encoded
      end
    end
  end

  test "android_group_links omits absent links" do
    with_env("GOOGLE_PLAY_GROUP_URL", nil) do
      with_env("GOOGLE_PLAY_OPEN_TESTING_URL", nil) do
        mail = BetaInviteMailer.android_group_links(@tester)
        assert_no_match "season2_beta_tester", mail.body.encoded
        assert_no_match "apps/testing", mail.body.encoded
      end
    end
  end
end
