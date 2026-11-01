require "test_helper"

class SuperpowersHelperTest < ActionView::TestCase
  test "superpower_label returns the English name in en" do
    I18n.with_locale(:en) do
      assert_equal "Developing/planning projects", superpower_label("Developing/planning projects")
      assert_equal "Self-confidence", superpower_label("Self-confidence")
    end
  end

  test "superpower_label returns the German name in de" do
    I18n.with_locale(:de) do
      assert_equal "Räumliches Denken", superpower_label("Spatial reasoning")
      assert_equal "Selbstvertrauen", superpower_label("Self-confidence")
      assert_equal "Entscheidungen treffen fällt leichter", superpower_label("Making decisions is easier")
    end
  end

  test "superpower_label translates every SUPERPOWERS entry in de" do
    I18n.with_locale(:de) do
      SuperpowersController::SUPERPOWERS.each do |name|
        assert_not_equal name, superpower_label(name), "missing de translation for #{name.inspect}"
      end
    end
  end

  test "superpower_label falls back to the raw name for an unknown entry" do
    I18n.with_locale(:de) do
      assert_equal "Something new", superpower_label("Something new")
    end
  end

  test "SUPERPOWERS stored keys stay English" do
    assert_includes SuperpowersController::SUPERPOWERS, "Spatial reasoning"
  end
end
