require "test_helper"

class SymptomLogTest < ActiveSupport::TestCase
  def setup
    @alice = users(:alice)
    @bob   = users(:bob)
  end

  test "is invalid without a date" do
    log = SymptomLog.new(user: @alice, date: nil)
    assert_not log.valid?
    assert_includes log.errors[:date], "can't be blank"
  end

  test "is valid with a date and user" do
    log = SymptomLog.new(user: @alice, date: Date.today)
    assert log.valid?
  end

  test "is invalid when same user logs twice on the same date" do
    SymptomLog.create!(user: @alice, date: Date.today)
    duplicate = SymptomLog.new(user: @alice, date: Date.today)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:date], "has already been taken"
  end

  test "allows two different users to log on the same date" do
    SymptomLog.create!(user: @alice, date: Date.today)
    bob_log = SymptomLog.new(user: @bob, date: Date.today)
    assert bob_log.valid?
  end
end
