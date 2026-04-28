require "test_helper"

class ReminderMailerTest < ActionMailer::TestCase
  setup do
    @alice = users(:alice)
  end

  test "morning_summary delivers to user email" do
    mail = ReminderMailer.morning_summary(@alice)
    assert_equal [@alice.email], mail.to
    assert_match "Good morning", mail.subject
  end

  test "morning_summary body includes phase information" do
    mail = ReminderMailer.morning_summary(@alice)
    assert_match(/menstrual|follicular|ovulation|luteal/i, mail.body.encoded)
  end

  test "morning_summary body includes user first name" do
    mail = ReminderMailer.morning_summary(@alice)
    assert_match "Alice", mail.body.encoded
  end

  test "period_reminder start delivers to user email" do
    mail = ReminderMailer.period_reminder(@alice, "period_start")
    assert_equal [@alice.email], mail.to
    assert_match "period", mail.subject.downcase
  end

  test "period_reminder end has different subject than start" do
    start_mail = ReminderMailer.period_reminder(@alice, "period_start")
    end_mail = ReminderMailer.period_reminder(@alice, "period_end")
    assert_not_equal start_mail.subject, end_mail.subject
  end

  test "birth_control_reminder delivers to user email" do
    mail = ReminderMailer.birth_control_reminder(@alice)
    assert_equal [@alice.email], mail.to
    assert_match "reminder", mail.subject.downcase
  end

  test "birth_control_reminder body includes contraception info" do
    mail = ReminderMailer.birth_control_reminder(@alice)
    assert_match(/contraception|pill|reminder/i, mail.body.encoded)
  end
end
