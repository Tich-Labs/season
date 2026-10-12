# frozen_string_literal: true

require "test_helper"

class TesterTourHelperTest < ActiveSupport::TestCase
  include TesterTourHelper
  include ActionView::Helpers::AssetTagHelper

  test "falls back to the English screenshot when no localized capture exists" do
    I18n.with_locale(:de) do
      assert_match %r{tester_tour/fallback-check\.png\z}, tester_tour_image("fallback-check")
    end
  end

  test "prefers the localized screenshot when one exists" do
    path = Rails.root.join("app/assets/images/tester_tour/test-shot-de.png")

    FileUtils.touch(path)

    I18n.with_locale(:de) do
      assert_match %r{tester_tour/test-shot-de\.png\z}, tester_tour_image("test-shot")
    end
  ensure
    FileUtils.rm_f(path)
  end
end
