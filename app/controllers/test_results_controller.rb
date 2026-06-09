class TestResultsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:submit]

  def submit
    tester_name = params[:tester_name].presence || "Unknown"
    platform = params[:platform].presence || "pwa"
    failures = params[:failures]

    unless failures.is_a?(Array) && failures.any?
      render json: {error: "No failures provided"}, status: :unprocessable_content
      return
    end

    count = 0
    failures.each do |f|
      next unless f["status"] == "fail"

      TrelloMailer.test_failure(
        tester_name: tester_name,
        platform: platform,
        section: f["section"] || "",
        scenario: f["scenario"] || "",
        priority: f["priority"] || "unknown",
        notes: f["notes"] || ""
      ).deliver_later
      count += 1
    end

    Rails.logger.info "TestResultsController: #{tester_name} submitted #{count} failures for #{platform}"

    render json: {sent: count, platform: platform}, status: :ok
  rescue => e
    Rails.logger.error "TestResultsController error: #{e.message}"
    render json: {error: "Server error"}, status: :internal_server_error
  end
end
