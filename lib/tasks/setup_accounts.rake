namespace :setup do
  desc "Promote naijeria@gmail.com to admin and create two confirmed test accounts"
  task accounts: :environment do
    # ── 1. Admin account ──────────────────────────────────────────────────────
    admin = User.find_or_initialize_by(email: "naijeria@gmail.com")
    if admin.new_record?
      admin.password = SecureRandom.hex(16)
      admin.name = "Naijeria"
      admin.skip_confirmation!
    else
      admin.skip_reconfirmation!
      admin.confirmed_at ||= Time.current
    end
    admin.admin = true
    admin.save!(validate: false)
    puts "✓ naijeria@gmail.com → admin=true, confirmed"

    # ── 2. Test accounts ──────────────────────────────────────────────────────
    test_accounts = [
      { email: "test1@seasonapp.co", name: "Test User One",  password: "Season2026!" },
      { email: "test2@seasonapp.co", name: "Test User Two",  password: "Season2026!" }
    ]

    test_accounts.each do |attrs|
      user = User.find_or_initialize_by(email: attrs[:email])
      user.name     = attrs[:name]
      user.password = attrs[:password]
      user.language = "en"
      user.onboarding_completed = false
      user.skip_confirmation!
      user.confirmed_at = Time.current
      user.save!(validate: false)
      puts "✓ #{attrs[:email]} — password: #{attrs[:password]}"
    end

    puts "\nDone. Share test account credentials with your team."
    puts "Admin panel: /admin  (log in as naijeria@gmail.com first)"
  end
end
