require "test_helper"

class FilterParametersTest < ActiveSupport::TestCase
  test "health and identity params are filtered from logs and Sentry breadcrumbs" do
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    params = {
      "symptom_log" => {
        "mood" => "4", "weight" => "62.5", "notes" => "tired", "sexual_intercourse" => "true",
        "intercourse_tags" => "protected", "physical_symptoms" => "cramps", "date" => "2026-10-06"
      },
      "user" => {"birthday" => "1990-01-01", "contraception_type" => "pill", "email" => "a@b.c"},
      "calendar_event" => {"title" => "Gynecologist", "guests" => "x@y.z"}
    }

    filtered = filter.filter(params)

    assert_equal "[FILTERED]", filtered["symptom_log"]["mood"]
    assert_equal "[FILTERED]", filtered["symptom_log"]["weight"]
    assert_equal "[FILTERED]", filtered["symptom_log"]["notes"]
    assert_equal "[FILTERED]", filtered["symptom_log"]["sexual_intercourse"]
    assert_equal "[FILTERED]", filtered["symptom_log"]["intercourse_tags"]
    assert_equal "[FILTERED]", filtered["symptom_log"]["physical_symptoms"]
    assert_equal "[FILTERED]", filtered["user"]["birthday"]
    assert_equal "[FILTERED]", filtered["user"]["contraception_type"]
    assert_equal "[FILTERED]", filtered["user"]["email"]
    assert_equal "[FILTERED]", filtered["calendar_event"]["title"]
    assert_equal "[FILTERED]", filtered["calendar_event"]["guests"]
    assert_equal "2026-10-06", filtered["symptom_log"]["date"]
  end
end
