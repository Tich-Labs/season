# app/services/apns_push_service.rb
# Requires the 'apnotic' gem for APNs push (add to Gemfile: gem 'apnotic')

require "apnotic"

class ApnsPushService
  def initialize(device_token, alert:, custom_payload: {}, apns_topic: ENV["APNS_BUNDLE_ID"])
    @device_token = device_token
    @alert = alert
    @custom_payload = custom_payload
    @apns_topic = apns_topic
  end

  def push
    connection = Apnotic::Connection.new(cert_path: ENV["APNS_CERT_PATH"])
    notification = Apnotic::Notification.new(@device_token)
    notification.alert = @alert
    notification.topic = @apns_topic
    @custom_payload.each { |k, v| notification.custom_payload[k] = v }
    response = connection.push(notification)
    connection.close
    response
  end
end
