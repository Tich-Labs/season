require "test_helper"

class SendPeriodRemindersJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "sends period_start email when period is exactly advance_days away" do
    alice = users(:alice)
    reminder = reminders(:alice_period_start)
    advance = reminder.advance_days

    # Set last_period_start so next period falls exactly advance_days from today
    cycle = alice.cycle_length
    target_start = Time.zone.today + advance
    new_last = target_start - cycle
    alice.update!(last_period_start: new_last)

    assert_emails 1 do
      SendPeriodRemindersJob.perform_now
    end
  end

  test "does not send when period is not advance_days away" do
    # last_period_start is 14 days ago (fixture default) — next period ~14 days away, not 2
    assert_emails 0 do
      SendPeriodRemindersJob.perform_now
    end
  end

  test "does not send when period reminder is inactive" do
    alice = users(:alice)
    reminder = reminders(:alice_period_start)
    advance = reminder.advance_days
    cycle = alice.cycle_length
    alice.update!(last_period_start: Time.zone.today + advance - cycle)

    reminders(:alice_period_start).update!(active: false)
    reminders(:alice_period_end).update!(active: false)

    assert_emails 0 do
      SendPeriodRemindersJob.perform_now
    end
  end
end
