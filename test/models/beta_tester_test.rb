require "test_helper"

class BetaTesterTest < ActiveSupport::TestCase
  test "requires a name, email, platform and consent" do
    tester = BetaTester.new

    assert_not tester.valid?
    assert_includes tester.errors[:name], "can't be blank"
    assert_includes tester.errors[:email], "can't be blank"
    assert_includes tester.errors[:platform], "can't be blank"
    assert_includes tester.errors[:beta_consent], "must be accepted before joining the beta."
  end

  test "downcases and strips emails before validation" do
    tester = BetaTester.new(
      name: "Alice Tester",
      email: "  ALICE@EXAMPLE.COM ",
      platform: "ios",
      beta_consent: true
    )

    assert tester.valid?
    assert_equal "alice@example.com", tester.email
  end

  test "rejects duplicate emails regardless of case" do
    BetaTester.create!(
      name: "Alice Tester",
      email: "alice@example.com",
      platform: "ios",
      beta_consent: true
    )

    duplicate = BetaTester.new(
      name: "Alice Again",
      email: "ALICE@EXAMPLE.COM",
      platform: "android",
      beta_consent: true
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "rejects malformed emails" do
    tester = BetaTester.new(name: "Bad", email: "not-an-email", platform: "ios", beta_consent: true)

    assert_not tester.valid?
    assert_includes tester.errors[:email], "is invalid"
  end

  test "rejects platforms outside the allowed set" do
    tester = BetaTester.new(name: "Alice", email: "a@example.com", platform: "toaster", beta_consent: true)

    assert_not tester.valid?
    assert_includes tester.errors[:platform], "is not included in the list"
  end

  test "defaults status to registered" do
    tester = BetaTester.create!(name: "Alice", email: "status@example.com", platform: "web", beta_consent: true)

    assert_equal "registered", tester.status
  end

  test "search scope matches name and email case-insensitively" do
    BetaTester.create!(name: "Ada Lovelace", email: "ada@example.com", platform: "ios", beta_consent: true)
    BetaTester.create!(name: "Grace Hopper", email: "grace@example.com", platform: "ios", beta_consent: true)

    assert_equal ["ada@example.com"], BetaTester.search("ADA@ex").map(&:email)
    assert_equal ["grace@example.com"], BetaTester.search("hopper").map(&:email)
    assert_empty BetaTester.search("nobody")
  end

  test "search scope escapes SQL LIKE wildcards" do
    BetaTester.create!(name: "Ada Lovelace", email: "ada@example.com", platform: "ios", beta_consent: true)

    assert_empty BetaTester.search("%")
  end

  test "platform and status scopes filter, and treat blank as no filter" do
    ios = BetaTester.create!(name: "I", email: "ios@example.com", platform: "ios", beta_consent: true)
    android = BetaTester.create!(name: "A", email: "and@example.com", platform: "android", beta_consent: true)

    assert_equal [ios.id], BetaTester.for_platform("ios").pluck(:id)
    assert_equal [android.id], BetaTester.for_platform("android").pluck(:id)
    assert_equal 2, BetaTester.with_status("registered").count

    # Blank means "don't filter", not "match nothing" — the admin list relies
    # on this when the select is left on its default.
    assert_equal 2, BetaTester.for_platform(nil).count
    assert_equal 2, BetaTester.for_platform("").count
    assert_equal 2, BetaTester.with_status(nil).count
    assert_equal 2, BetaTester.with_status("").count
    assert_equal 2, BetaTester.search(nil).count
  end
end
