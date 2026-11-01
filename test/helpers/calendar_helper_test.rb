require "test_helper"

class CalendarHelperTest < ActionView::TestCase
  setup do
    @date = Date.new(2026, 1, 1)
  end

  test "event_card_date renders the English card format with an ordinal day" do
    I18n.with_locale(:en) do
      assert_equal "Thu. Jan 1st 2026", event_card_date(@date)
    end
  end

  test "event_card_date renders German weekday, day-with-dot and month in de" do
    I18n.with_locale(:de) do
      assert_equal "Do., 1. Jan 2026", event_card_date(@date)
    end
  end

  test "superpower_day format renders German weekday and month names in de" do
    I18n.with_locale(:de) do
      assert_equal "Donnerstag, 1. Januar", l(@date, format: :superpower_day)
    end
  end

  test "superpower_day format renders English names in en" do
    I18n.with_locale(:en) do
      assert_equal "Thursday, 1 January", l(@date, format: :superpower_day)
    end
  end

  test "repeat_until_label renders German month names in de" do
    I18n.with_locale(:de) do
      assert_equal "Do, 01. Jan 2026", l(@date, format: :repeat_until_label)
    end
  end
end
