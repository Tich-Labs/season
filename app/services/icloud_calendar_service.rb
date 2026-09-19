require "net/http"
require "nokogiri"
require "icalendar"

# Net::HTTP ships PROPFIND out of the box, but not REPORT (the other
# WebDAV verb CalDAV needs, for the actual event query) -- this is the
# standard way to add a custom HTTP method to Net::HTTP, no gem needed.
module Net
  class HTTP
    class Report < HTTPRequest
      METHOD = "REPORT"
      REQUEST_HAS_BODY = true
      RESPONSE_HAS_BODY = true
    end
  end
end

# Pull-only, read from the user's iCloud Calendar via CalDAV. There is no
# OAuth for iCloud Calendar access -- the user generates an app-specific
# password at appleid.apple.com and gives us their Apple ID email + that
# password, used as HTTP Basic Auth against Apple's CalDAV server. Unlike
# Google's REST/JSON API, CalDAV is HTTP+XML (WebDAV) with events returned
# as raw iCalendar (.ics) text -- reading a user's events takes a
# 3-request discovery chain (find their principal, then their calendar
# home, then the calendars in it) before a 4th request can actually query
# events in a date range.
class IcloudCalendarService
  BASE_URL = "https://caldav.icloud.com"
  NS = {"D" => "DAV:", "C" => "urn:ietf:params:xml:ns:caldav"}.freeze

  Event = Struct.new(:uid, :summary, :description, :location, :starts_at, :ends_at, keyword_init: true)

  class AuthenticationError < StandardError; end

  def initialize(user)
    @user = user
  end

  # Called from the connect form before saving credentials -- a wrong
  # app-specific password should fail loudly right there, not silently on
  # the first background sync. Raises AuthenticationError on a bad
  # email/password pair; returns true on success.
  def self.verify_credentials!(email, app_password)
    new(User.new(icloud_email: email, icloud_app_password: app_password)).discover_calendar_urls
    true
  end

  def list_events(time_min:, time_max:)
    return [] unless @user.icloud_connected?

    discover_calendar_urls.flat_map { |calendar_url| query_events(calendar_url, time_min, time_max) }
  rescue AuthenticationError
    nil
  end

  # Public so .verify_credentials! can drive the same discovery chain
  # without needing a real event query.
  def discover_calendar_urls
    principal_href = propfind_single(BASE_URL, PRINCIPAL_BODY, "//D:current-user-principal/D:href")
    raise AuthenticationError, "could not discover principal (check Apple ID + app-specific password)" if principal_href.blank?

    home_set_href = propfind_single(absolute_url(principal_href), HOME_SET_BODY, "//C:calendar-home-set/D:href")
    raise AuthenticationError, "could not discover calendar home set" if home_set_href.blank?

    doc = propfind(absolute_url(home_set_href), CALENDARS_BODY, depth: "1")
    doc.xpath("//D:response", NS).filter_map do |response|
      href = response.at_xpath("D:href", NS)&.text
      is_calendar = response.at_xpath(".//D:resourcetype/C:calendar", NS)
      absolute_url(href) if href.present? && is_calendar && absolute_url(href) != absolute_url(home_set_href)
    end
  end

  private

  PRINCIPAL_BODY = <<~XML
    <?xml version="1.0" encoding="utf-8" ?>
    <D:propfind xmlns:D="DAV:">
      <D:prop><D:current-user-principal/></D:prop>
    </D:propfind>
  XML

  HOME_SET_BODY = <<~XML
    <?xml version="1.0" encoding="utf-8" ?>
    <D:propfind xmlns:D="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
      <D:prop><C:calendar-home-set/></D:prop>
    </D:propfind>
  XML

  CALENDARS_BODY = <<~XML
    <?xml version="1.0" encoding="utf-8" ?>
    <D:propfind xmlns:D="DAV:">
      <D:prop>
        <D:resourcetype/>
        <D:displayname/>
      </D:prop>
    </D:propfind>
  XML

  def query_events(calendar_url, time_min, time_max)
    body = <<~XML
      <?xml version="1.0" encoding="utf-8" ?>
      <C:calendar-query xmlns:D="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
        <D:prop>
          <D:getetag/>
          <C:calendar-data/>
        </D:prop>
        <C:filter>
          <C:comp-filter name="VCALENDAR">
            <C:comp-filter name="VEVENT">
              <C:time-range start="#{time_min.strftime("%Y%m%dT%H%M%SZ")}" end="#{time_max.strftime("%Y%m%dT%H%M%SZ")}"/>
            </C:comp-filter>
          </C:comp-filter>
        </C:filter>
      </C:calendar-query>
    XML

    doc = report(calendar_url, body, depth: "1")
    doc.xpath("//D:response", NS).filter_map { |response| parse_event(response) }
  end

  def parse_event(response)
    ics = response.at_xpath(".//C:calendar-data", NS)&.text
    return nil if ics.blank?

    vevent = Icalendar::Calendar.parse(ics).first&.events&.first
    return nil unless vevent

    Event.new(
      uid: vevent.uid.to_s,
      summary: vevent.summary.to_s,
      description: vevent.description.to_s,
      location: vevent.location.to_s,
      starts_at: to_time(vevent.dtstart),
      ends_at: to_time(vevent.dtend || vevent.dtstart)
    )
  rescue Icalendar::Parser::ParseError => e
    Rails.logger.warn("[IcloudCalendarService] failed to parse event: #{e.message}")
    nil
  end

  def to_time(value)
    return nil unless value
    value.respond_to?(:to_time) ? value.to_time : Time.zone.parse(value.to_s)
  end

  def propfind_single(url, body, xpath)
    propfind(url, body, depth: "0").at_xpath(xpath, NS)&.text
  end

  def propfind(url, body, depth:)
    parse_response(request(Net::HTTP::Propfind, url, body: body, depth: depth))
  end

  def report(url, body, depth:)
    parse_response(request(Net::HTTP::Report, url, body: body, depth: depth))
  end

  def parse_response(response)
    case response
    when Net::HTTPUnauthorized, Net::HTTPForbidden
      raise AuthenticationError, "iCloud rejected the Apple ID / app-specific password"
    when Net::HTTPMultiStatus, Net::HTTPSuccess
      Nokogiri::XML(response.body)
    else
      raise "iCloud CalDAV request failed: #{response.code} #{response.message}"
    end
  end

  def request(method_class, url, body:, depth:)
    uri = URI(url)
    req = method_class.new(uri)
    req.basic_auth(@user.icloud_email, @user.icloud_app_password)
    req["Depth"] = depth
    req["Content-Type"] = "application/xml; charset=utf-8"
    req.body = body
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
  end

  def absolute_url(href)
    return href if href.start_with?("http")
    URI.join(BASE_URL, href).to_s
  end
end
