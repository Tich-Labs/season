# frozen_string_literal: true

module Beta
  module BetaHelper
    def beta_platform_options
      [
        {value: "iOS", label: "Apple iOS"},
        {value: "Android", label: "Android"},
        {value: "Web", label: "Web"}
      ]
    end

    def beta_logo_asset
      "season-wortmarke-1.svg"
    end

    # Language switching keeps you on the screen you are already looking at.
    # Hardcoding /beta here used to drop someone on step 1 and throw away
    # whatever they had typed, and a legal document switched back to step 1
    # instead of staying on that document.
    def beta_switch_locale_path(locale)
      query = request.query_parameters.except("locale").merge("locale" => locale)
      query.empty? ? request.path : "#{request.path}?#{query.to_query}"
    end
  end
end
