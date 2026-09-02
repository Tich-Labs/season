# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"

abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "capybara/rspec"

Capybara.app = Rails.application

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [
    Rails.root.join("spec/fixtures")
  ]

  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::IntegrationHelpers
  # This is set, but records created via `create(:user)` were still found
  # persisting in the test DB across separate `bundle exec rspec`
  # invocations (confirmed: run the suite, then check
  # `User.where("email LIKE 'user%@example.com'")` in a fresh `rails
  # runner` — rows are still there). Worth root-causing properly
  # (suspect a connection-handling interaction with request/feature specs
  # specifically, since a model-only run showed no leak across repeats) —
  # not done here since restructuring transaction/connection handling
  # isn't a safe change to make blind right before launch. Factory emails
  # are now collision-proof regardless (see spec_helper.rb), so this
  # doesn't fail tests, but the DB is still quietly accumulating orphaned
  # test rows every run.
  config.use_transactional_fixtures = true
end
