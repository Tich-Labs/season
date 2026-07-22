module RubyNative
  module Helper
    def native_navbar_tag(title = nil, pull_to_refresh: true, &block)
      builder = NavbarBuilder.new(self)
      capture(builder, &block) if block

      data = {native_navbar: title.to_s}
      data[:native_pull_to_refresh] = "false" unless pull_to_refresh

      bg = content_for(:header_color).presence
      if bg
        data[:native_navbar_bg] = bg
        data[:native_navbar_fg] = "#FFFFFF"
      elsif content_for(:header_dark).present?
        data[:native_navbar_bg] = "#933a35"
        data[:native_navbar_fg] = "#FFFFFF"
      else
        data[:native_navbar_bg] = "#EDE1D5"
        data[:native_navbar_fg] = "#933a35"
      end

      tag.div(data: data, hidden: true) { builder.to_html }
    end
  end
end
