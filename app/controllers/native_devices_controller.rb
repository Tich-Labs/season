class NativeDevicesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:register]

  # POST /native_devices/register
  def register
    device_token = params[:device_token]
    platform = params[:platform] || "ios"
    app_version = params[:app_version]

    if device_token.blank?
      render json: {error: "device_token required"}, status: :bad_request and return
    end

    # current_user, not a client-supplied params[:user_id] — this endpoint is
    # authenticated (see Authentication#authenticate_user), so there's no
    # reason to trust the caller's own claim of whose account a device token
    # belongs to. Letting the request name an arbitrary user_id let anyone
    # register their device against someone else's account.
    device = NativeDevice.find_or_initialize_by(device_token: device_token)
    device.user_id = current_user.id
    device.platform = platform
    device.app_version = app_version
    device.save!

    render json: {status: "ok"}
  rescue => e
    render json: {error: e.message}, status: :unprocessable_content
  end
end
