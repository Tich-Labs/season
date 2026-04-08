require "test_helper"

class CyclePhaseContentTest < ActiveSupport::TestCase
  test ".for returns English content for en locale" do
    content = CyclePhaseContent.for("menstrual", "en")
    assert_not_nil content
    assert_equal "en", content.locale
    assert_equal "menstrual", content.phase
  end

  test ".for returns German content for de locale" do
    content = CyclePhaseContent.for("menstrual", "de")
    assert_not_nil content
    assert_equal "de", content.locale
    assert_equal "menstrual", content.phase
  end

  test ".for falls back to English for an unknown locale" do
    content = CyclePhaseContent.for("menstrual", "fr")
    assert_not_nil content
    assert_equal "en", content.locale
  end

  test ".for returns nil when phase does not exist at all" do
    content = CyclePhaseContent.for("nonexistent_phase", "en")
    assert_nil content
  end

  test ".for defaults locale to en when omitted" do
    content = CyclePhaseContent.for("menstrual")
    assert_not_nil content
    assert_equal "en", content.locale
  end
end
