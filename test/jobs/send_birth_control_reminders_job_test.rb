require "test_helper"

class SendBirthControlRemindersJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "enqueues emails for users with active pill reminders" do
    assert_emails 1 do
      SendBirthControlRemindersJob.perform_now
    end
  end

  test "does not send when pill reminder is inactive" do
    reminders(:alice_pill).update!(active: false)
    assert_emails 0 do
      SendBirthControlRemindersJob.perform_now
    end
  end
end
