module TurboNativeHelper
  def web_only?
    !native_app?
  end
end
