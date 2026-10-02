# frozen_string_literal: true

namespace :beta_testers do
  desc "Link beta testers to their app User accounts by email (backfill)"
  task link_users: :environment do
    linked = 0

    BetaTester.where(user_id: nil).find_each do |tester|
      user = User.where("LOWER(email) = ?", tester.email).order(:created_at).last
      next unless user

      tester.update!(user: user)
      tester.update!(status: "active") unless tester.completed?
      linked += 1
    end

    puts "Linked #{linked} beta tester(s) to app accounts."
  end
end
