# frozen_string_literal: true

# Static legal content loaded from authored HTML files under docs/legal/.
# We serve the <body> of that file, run it through an allowlist sanitizer, and
# expose a stable SHA-256 of the served body. Redcarpet is not used.
class Legal::Content
  LANGUAGES = %w[de en].freeze
  TYPES = %w[terms privacy].freeze

  # The authored documents only ever use <p> and <h4> and carry no attributes,
  # so the allowlist is deliberately minimal. Anything else -- <script>,
  # <iframe>, event handlers, javascript: URLs -- is dropped rather than
  # trusted, which means a mistake in an authored file cannot inject code.
  ALLOWED_TAGS = %w[p h4 ul ol li strong em b i br].freeze
  ALLOWED_ATTRIBUTES = [].freeze

  def self.find(type:, locale:)
    new(type:, locale:)
  end

  def initialize(type:, locale:)
    @type = type.to_s
    @locale = locale.to_s
    raise ArgumentError, "invalid type" unless TYPES.include?(@type)
    raise ArgumentError, "invalid locale" unless LANGUAGES.include?(@locale)
  end

  attr_reader :type

  def title
    case [@type, @locale]
    when %w[terms de] then "Teilnahmebedingungen"
    when %w[terms en] then "Terms of Participation"
    when %w[privacy de] then "Datenschutzhinweise"
    when %w[privacy en] then "Privacy Notice"
    else "Legal"
    end
  end

  def version = "1.0"

  # Only the content of <body> is served. The surrounding document
  # (<!doctype>, <html>, <head>, <title>) is authoring scaffolding and would
  # nest an invalid document inside the page layout. The document's own <h1>
  # is dropped too, because the layout already renders `title` as the page
  # heading — keeping both showed the heading twice.
  # Returns an already-sanitized SafeBuffer, so the view can interpolate it
  # directly instead of calling raw on it. body_sha256 digests exactly what is
  # served, so the recorded consent hash still matches the visible copy.
  def body
    doc = Nokogiri::HTML.parse(file_content)
    node = doc.at_css("body")
    fragment = node ? node.inner_html : file_content
    cleaned = strip_open_markers(drop_document_title(fragment)).strip

    # The allowlist sanitizer drops a disallowed tag but leaves its inner text,
    # so a <script> body would end up rendered as visible prose. Remove those
    # elements outright first, contents included.
    cleaned = cleaned.gsub(%r{<(script|style|iframe|noscript)\b.*?</\1>}mi, "")
      .gsub(/<!--.*?-->/m, "")

    ActiveSupport::SafeBuffer.new(
      Rails::Html::SafeListSanitizer.new.sanitize(
        cleaned, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES
      )
    )
  end

  def body_sha256
    Digest::SHA256.hexdigest(body)
  end

  private

  def file_path
    Rails.root.join("docs", "legal", "#{@type}.#{@locale}.html")
  end

  def file_content
    File.read(file_path)
  rescue Errno::ENOENT
    Rails.root.join("docs", "legal", "#{@type}.en.html").read
  end

  def drop_document_title(html)
    html.sub(%r{\A\s*<h1[^>]*>.*?</h1>}mi, "")
  end

  def strip_open_markers(text)
    text.gsub(/\[OPEN[^\]]*\]/i, "")
  end
end
