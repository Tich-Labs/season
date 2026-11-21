require "test_helper"

class I18nTest < ActiveSupport::TestCase
  test "German appointment date range labels are translated" do
    I18n.with_locale(:de) do
      assert_equal "Von", I18n.t("calendar_events.form.from")
      assert_equal "Bis", I18n.t("calendar_events.form.to")
    end
  end
end
