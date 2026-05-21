namespace :vapid do
  desc "Generate VAPID keys for Web Push notifications"
  task generate: :environment do
    require "webpush"
    vapid_key = WebPush.generate_key
    puts "Add these to your credentials with:"
    puts "  rails credentials:edit"
    puts ""
    puts "vapid:"
    puts "  public_key: #{vapid_key.public_key}"
    puts "  private_key: #{vapid_key.private_key}"
  end
end
