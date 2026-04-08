require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @alice = users(:alice)
  end

  # --- Validations ---

  test "is invalid without email" do
    user = User.new(email: "", password: "password123", name: "Test")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "is invalid with duplicate email" do
    duplicate = User.new(
      email: @alice.email,
      password: "password123",
      name: "Duplicate"
    )
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  # --- Instance methods ---

  test "first_name returns first word of full name" do
    assert_equal "Alice", @alice.first_name
  end

  test "first_name returns full name when single word" do
    @alice.name = "Mononymous"
    assert_equal "Mononymous", @alice.first_name
  end

  test "first_name returns nil when name is nil" do
    @alice.name = nil
    assert_nil @alice.first_name
  end

  # --- current_phase ---

  test "current_phase returns nil when last_period_start is not set" do
    user = User.create!(
      email: "no_period@example.com",
      password: "password123",
      name: "No Period"
    )
    assert_nil user.current_phase
  end

  test "current_phase returns a string when last_period_start is set" do
    @alice.last_period_start = 7.days.ago.to_date
    @alice.cycle_length = 28
    @alice.period_length = 5
    result = @alice.current_phase
    assert_kind_of String, result
    assert_includes %w[menstrual follicular ovulation luteal], result
  end

  # --- Associations cascade ---

  test "destroying user cascade-destroys symptom_logs" do
    user = User.create!(
      email: "cascade_test@example.com",
      password: "password123",
      name: "Cascade Test"
    )
    SymptomLog.create!(user: user, date: Date.today)
    assert_difference "SymptomLog.count", -1 do
      user.destroy
    end
  end

  test "destroying user cascade-destroys streak" do
    user = User.create!(
      email: "cascade_streak@example.com",
      password: "password123",
      name: "Cascade Streak"
    )
    Streak.create!(user: user)
    assert_difference "Streak.count", -1 do
      user.destroy
    end
  end

  test "destroying user cascade-destroys calendar_events" do
    user = User.create!(
      email: "cascade_events@example.com",
      password: "password123",
      name: "Cascade Events"
    )
    CalendarEvent.create!(user: user, title: "Test event", date: Date.today)
    assert_difference "CalendarEvent.count", -1 do
      user.destroy
    end
  end
end
