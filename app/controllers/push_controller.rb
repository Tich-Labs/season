class PushController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:subscribe, :unsubscribe]

  def vapid_public_key
    key = Rails.application.credentials.dig(:vapid, :public_key) ||
      Rails.application.credentials.dig(:vapid, "public_key") ||
      ENV["VAPID_PUBLIC_KEY"]
    render json: {public_key: key}
  end

  def subscribe
    sub = params[:subscription]
    device_type = params[:device_type] || "browser"

    existing = current_user.push_subscriptions.find_by(endpoint: sub[:endpoint])
    unless existing
      current_user.push_subscriptions.create!(
        endpoint: sub[:endpoint],
        p256dh_key: sub.dig(:keys, :p256dh),
        auth_key: sub.dig(:keys, :auth),
        device_type: device_type
      )
    end

    render json: {success: true}
  rescue ActiveRecord::RecordNotUnique
    render json: {success: true}
  end

  def unsubscribe
    current_user.push_subscriptions.destroy_all
    render json: {success: true}
  end
end
