require "test_helper"

class DataRetentionJobTest < ActiveJob::TestCase
  def tester(email, user: nil)
    BetaTester.create!(
      name: "Tester", email: email, platform: "ios", beta_consent: true, user: user
    )
  end

  def consent_for(beta_tester, created_at:)
    ConsentRecord.create!(
      beta_tester: beta_tester, consent_type: "terms", granted: true, doc_version: "1.0",
      language: "en", text_sha256: "a" * 64, created_at: created_at
    )
  end

  test "purges old consent records of testers without an account" do
    gone = consent_for(tester("gone@example.com"), created_at: 4.years.ago)

    DataRetentionJob.perform_now

    assert_not ConsentRecord.exists?(gone.id)
  end

  test "keeps consent records younger than the retention period" do
    recent = consent_for(tester("recent@example.com"), created_at: 1.year.ago)

    DataRetentionJob.perform_now

    assert ConsentRecord.exists?(recent.id)
  end

  test "keeps old consent records while the tester still has an account" do
    active = consent_for(tester("active@example.com", user: users(:alice)), created_at: 4.years.ago)

    DataRetentionJob.perform_now

    assert ConsentRecord.exists?(active.id)
  end
end
