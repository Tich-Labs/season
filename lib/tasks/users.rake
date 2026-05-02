namespace :users do
  desc "Seed users from CSV file"
  task :seed_invites, [:file] => :environment do |t, args|
    require "csv"
    file = args[:file] || "db/users.csv"
    count = 0

    if File.exist?(file)
      CSV.foreach(file, headers: true) do |row|
        next if row["email"].blank?

        user = User.find_or_initialize_by(
          email: row["email"].strip.downcase
        )
        if user.new_record?
          user.name = row["name"].strip if row["name"].present?
          user.invite_token = SecureRandom.urlsafe_base64(16)
          user.invite_token_expires_at = 7.days.from_now
          user.password = SecureRandom.hex(16)
          user.onboarding_completed = false
          user.language = "en"
          user.save!
          count += 1
        end
      end
      Rails.logger.info "Seeded #{count} invite users"
    else
      Rails.logger.warn "File #{file} not found. Create a CSV with columns: name,email"
    end
  end
end
