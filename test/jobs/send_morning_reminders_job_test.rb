require "test_helper"

class SendMorningRemindersJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "enqueues emails for users with active morning reminders" do
    assert_emails 1 do
      SendMorningRemindersJob.perform_now
    end
  end

  test "does not send to users with inactive morning reminders" do
    reminders(:alice_morning).update!(active: false)
    assert_emails 0 do
      SendMorningRemindersJob.perform_now
    end
  end
end
