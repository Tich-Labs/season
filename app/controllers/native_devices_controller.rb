class NativeDevicesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:register]

  # POST /native_devices/register
  def register
    device_token = params[:device_token]
    user_id = params[:user_id]
    platform = params[:platform] || "ios"
    app_version = params[:app_version]

    if device_token.blank?
      render json: {error: "device_token required"}, status: :bad_request and return
    end

    device = NativeDevice.find_or_initialize_by(device_token: device_token)
    device.user_id = user_id if user_id.present?
    device.platform = platform
    device.app_version = app_version
    device.save!

    render json: {status: "ok"}
  rescue => e
    render json: {error: e.message}, status: :unprocessable_content
  end
end
