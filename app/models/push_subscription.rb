class PushSubscription < ApplicationRecord
  belongs_to :user

  validates :endpoint, presence: true, uniqueness: true
  validates :p256dh_key, presence: true
  validates :auth_key, presence: true

  def send_notification(title, body, url = "/")
    vapid_keys = vapid_credentials
    return unless vapid_keys

    WebPush.payload_send(
      endpoint: endpoint,
      p256dh: p256dh_key,
      auth: auth_key,
      message: {title: title, body: body, icon: "/icon.png", badge: "/favicon.png", data: {url: url}}.to_json,
      vapid: vapid_keys
    )
  rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
    destroy
  end

  private

  def vapid_credentials
    creds = Rails.application.credentials.dig(:vapid)
    if creds.present?
      pub = creds[:public_key] || creds["public_key"]
      priv = creds[:private_key] || creds["private_key"]
      return {subject: "mailto:hello@season.app", public_key: pub, private_key: priv} if pub && priv
    end

    if ENV["VAPID_PUBLIC_KEY"] && ENV["VAPID_PRIVATE_KEY"]
      return {
        subject: "mailto:hello@season.app",
        public_key: ENV["VAPID_PUBLIC_KEY"],
        private_key: ENV["VAPID_PRIVATE_KEY"]
      }
    end
    nil
  end
end
