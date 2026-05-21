class PushNotificationService
  def self.send_to_user(user, title:, body:, url: "/")
    user.push_subscriptions.each do |sub|
      sub.send_notification(title, body, url)
    rescue => e
      Rails.logger.warn "Push send failed for #{sub.id}: #{e.message}"
    end
  end

  def self.send_to_all(title:, body:, url: "/")
    PushSubscription.find_each do |sub|
      sub.send_notification(title, body, url)
    rescue => e
      Rails.logger.warn "Push send failed for #{sub.id}: #{e.message}"
    end
  end
end
