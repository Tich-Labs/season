class AppLinksController < ApplicationController
  allow_unauthenticated_access
  allow_pin_bypass

  IOS_BUNDLE_ID = "com.onrender.seasonv2.rubynative"
  ANDROID_PACKAGE_NAME = "com.onrender.seasonv2.rubynative"
  ANDROID_SHA256_FINGERPRINT = "E3:52:3C:60:16:32:04:0F:00:0B:68:4D:75:22:EB:46:B0:DF:14:8C:AA:ED:FF:1D:40:16:E0:FC:F0:DF:96:C7"

  def apple_app_site_association
    render json: {
      applinks: {
        apps: [],
        details: [
          {
            appID: "#{ENV.fetch("APPLE_TEAM_ID", "28NDQR5JC4")}.#{ENV.fetch("IOS_BUNDLE_ID", IOS_BUNDLE_ID)}",
            paths: ["/users/password/*", "/password/*"]
          }
        ]
      }
    }
  end

  def assetlinks
    render json: [
      {
        relation: ["delegate_permission/common.handle_all_urls"],
        target: {
          namespace: "android_app",
          package_name: ENV.fetch("GOOGLE_PLAY_PACKAGE_NAME", ANDROID_PACKAGE_NAME),
          sha256_cert_fingerprints: [
            ENV["ANDROID_APP_LINKS_SHA256"].presence || ANDROID_SHA256_FINGERPRINT
          ]
        }
      }
    ]
  end
end
