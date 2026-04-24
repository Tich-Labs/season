module IconHelper
  VUESAX_PATH = Rails.root.join("app/assets/images/icons/vuesax/linear")
  CUSTOM_PATH = Rails.root.join("app/assets/images/icons/custom")

  # Render a Vuesax linear icon inline, with optional colour override.
  #
  # Usage:
  #   <%= vuesax_icon "calendar-add", size: 24 %>
  #   <%= vuesax_icon "notification", size: 20, colour: "#933a35" %>
  #
  # colour defaults to "#933a35" (Season brand). Pass colour: nil to keep the
  # original #292D32 from the exported SVG.
  def vuesax_icon(name, size: 24, colour: "#933a35", **attrs)
    svg_icon(VUESAX_PATH.join("#{name}.svg"), size: size, colour: colour, default_stroke: "#292D32", **attrs)
  end

  # Render a custom Season illustration icon inline.
  #
  # Usage:
  #   <%= custom_icon "flower-tulip", size: 48 %>
  #   <%= custom_icon "calendar-blocked", size: 64, colour: "#933a35" %>
  #
  # colour defaults to nil (keep the original #4D4D4D). Pass a hex to recolour.
  def custom_icon(name, size: nil, colour: nil, **attrs)
    svg_icon(CUSTOM_PATH.join("#{name}.svg"), size: size, colour: colour, default_stroke: "#4D4D4D", **attrs)
  end

  private

  def svg_icon(path, size:, colour:, default_stroke:, **attrs)
    raw = File.read(path)
  rescue Errno::ENOENT
    "".html_safe
  else
    # Replace width/height attributes when a size is given
    if size
      raw = raw.sub(/(<svg[^>]*)\swidth="[^"]*"/, "\\1 width=\"#{size}\"")
        .sub(/(<svg[^>]*)\sheight="[^"]*"/, "\\1 height=\"#{size}\"")
    end

    # Recolour stroke and fill (only non-none fills)
    if colour
      raw = raw.gsub(/stroke="#{Regexp.escape(default_stroke)}"/, "stroke=\"#{colour}\"")
        .gsub(/fill="#{Regexp.escape(default_stroke)}"/, "fill=\"#{colour}\"")
    end

    # Merge extra HTML attributes (aria-hidden, class, style, etc.) into <svg>
    unless attrs.empty?
      attr_str = attrs.map { |k, v| "#{k.to_s.tr("_", "-")}=\"#{v}\"" }.join(" ")
      raw = raw.sub("<svg", "<svg #{attr_str}")
    end

    raw.html_safe # rubocop:disable Rails/OutputSafety -- SVG read from app's own asset files, not user input
  end
end
