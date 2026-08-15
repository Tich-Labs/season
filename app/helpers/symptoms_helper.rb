module SymptomsHelper
  # Finger photos for the discharge info modal are added incrementally per
  # category — image_tag raises Propshaft::MissingAssetError (a 500, not a
  # broken <img>) for a path with no matching source file, so this has to be
  # checked before rendering the tag at all, not worked around client-side.
  def discharge_finger_photo_exists?(key)
    Rails.root.join("app/assets/images/vaginal_discharge/finger/#{key}.jpg").exist?
  end

  # Finger videos (converted to H.264 MP4) for the discharge info modal.
  # Same existence check as the photos above — Propshaft raises on a missing
  # source file, so the <video> tag is skipped entirely when absent.
  def discharge_finger_video_exists?(key)
    Rails.root.join("app/assets/images/vaginal_discharge/finger/#{key}.mp4").exist?
  end
end
