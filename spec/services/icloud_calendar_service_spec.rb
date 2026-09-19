require "rails_helper"

ICLOUD_SPEC_PRINCIPAL_XML = <<~XML
  <?xml version="1.0"?>
  <D:multistatus xmlns:D="DAV:">
    <D:response>
      <D:href>/</D:href>
      <D:propstat>
        <D:prop><D:current-user-principal><D:href>/12345/principal/</D:href></D:current-user-principal></D:prop>
      </D:propstat>
    </D:response>
  </D:multistatus>
XML

ICLOUD_SPEC_HOME_SET_XML = <<~XML
  <?xml version="1.0"?>
  <D:multistatus xmlns:D="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
    <D:response>
      <D:href>/12345/principal/</D:href>
      <D:propstat>
        <D:prop><C:calendar-home-set><D:href>/12345/calendars/</D:href></C:calendar-home-set></D:prop>
      </D:propstat>
    </D:response>
  </D:multistatus>
XML

ICLOUD_SPEC_CALENDARS_XML = <<~XML
  <?xml version="1.0"?>
  <D:multistatus xmlns:D="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
    <D:response>
      <D:href>/12345/calendars/</D:href>
      <D:propstat><D:prop><D:resourcetype><D:collection/></D:resourcetype></D:prop></D:propstat>
    </D:response>
    <D:response>
      <D:href>/12345/calendars/home/</D:href>
      <D:propstat><D:prop><D:resourcetype><D:collection/><C:calendar/></D:resourcetype></D:prop></D:propstat>
    </D:response>
  </D:multistatus>
XML

ICLOUD_SPEC_EVENT_ICS = <<~ICS.gsub("\n", "\r\n")
  BEGIN:VCALENDAR
  VERSION:2.0
  BEGIN:VEVENT
  UID:event-1@icloud.com
  SUMMARY:Dentist
  DTSTART:20260919T093000Z
  DTEND:20260919T100000Z
  DESCRIPTION:Annual checkup
  LOCATION:Main St Clinic
  END:VEVENT
  END:VCALENDAR
ICS

ICLOUD_SPEC_EVENTS_XML = <<~XML
  <?xml version="1.0"?>
  <D:multistatus xmlns:D="DAV:" xmlns:C="urn:ietf:params:xml:ns:caldav">
    <D:response>
      <D:href>/12345/calendars/home/event-1.ics</D:href>
      <D:propstat><D:prop><C:calendar-data>#{ICLOUD_SPEC_EVENT_ICS}</C:calendar-data></D:prop></D:propstat>
    </D:response>
  </D:multistatus>
XML

RSpec.describe IcloudCalendarService do
  def fake_response(klass, body)
    response = klass.allocate
    response.instance_variable_set(:@code, (klass == Net::HTTPUnauthorized) ? "401" : "207")
    response.instance_variable_set(:@body, body)
    response.instance_variable_set(:@read, true)
    response
  end

  let(:user) { create(:user, :onboarded, icloud_email: "test@icloud.com", icloud_app_password: "app-specific-pw") }
  let(:service) { described_class.new(user) }

  def stub_success_chain
    responses = {
      "PROPFIND /" => fake_response(Net::HTTPMultiStatus, ICLOUD_SPEC_PRINCIPAL_XML),
      "PROPFIND /12345/principal/" => fake_response(Net::HTTPMultiStatus, ICLOUD_SPEC_HOME_SET_XML),
      "PROPFIND /12345/calendars/" => fake_response(Net::HTTPMultiStatus, ICLOUD_SPEC_CALENDARS_XML),
      "REPORT /12345/calendars/home/" => fake_response(Net::HTTPMultiStatus, ICLOUD_SPEC_EVENTS_XML)
    }
    allow(Net::HTTP).to receive(:start) do |_host, _port, **_opts, &block|
      fake_http = instance_double(Net::HTTP)
      allow(fake_http).to receive(:request) do |req|
        key = "#{req.method} #{req.path}"
        responses.fetch(key) { raise "unstubbed request: #{key}" }
      end
      block.call(fake_http)
    end
  end

  describe "#discover_calendar_urls" do
    it "walks the principal -> home-set -> calendars discovery chain" do
      stub_success_chain

      urls = service.discover_calendar_urls

      expect(urls).to eq(["https://caldav.icloud.com/12345/calendars/home/"])
    end

    it "raises AuthenticationError on a 401" do
      allow(Net::HTTP).to receive(:start) do |_host, _port, **_opts, &block|
        fake_http = instance_double(Net::HTTP)
        allow(fake_http).to receive(:request).and_return(fake_response(Net::HTTPUnauthorized, ""))
        block.call(fake_http)
      end

      expect { service.discover_calendar_urls }.to raise_error(described_class::AuthenticationError)
    end
  end

  describe "#list_events" do
    it "returns [] for a user who hasn't connected iCloud" do
      unconnected = create(:user, :onboarded)
      expect(described_class.new(unconnected).list_events(time_min: 1.day.ago, time_max: 1.day.from_now)).to eq([])
    end

    it "parses the returned iCalendar data into Event structs" do
      stub_success_chain

      events = service.list_events(time_min: 1.day.ago, time_max: 7.days.from_now)

      expect(events.size).to eq(1)
      event = events.first
      expect(event.uid).to eq("event-1@icloud.com")
      expect(event.summary).to eq("Dentist")
      expect(event.description).to eq("Annual checkup")
      expect(event.location).to eq("Main St Clinic")
      expect(event.starts_at).to be_a(Time).or be_a(DateTime)
    end

    it "returns nil (not raise) when credentials are rejected" do
      allow(Net::HTTP).to receive(:start) do |_host, _port, **_opts, &block|
        fake_http = instance_double(Net::HTTP)
        allow(fake_http).to receive(:request).and_return(fake_response(Net::HTTPUnauthorized, ""))
        block.call(fake_http)
      end

      expect(service.list_events(time_min: 1.day.ago, time_max: 1.day.from_now)).to be_nil
    end
  end

  describe ".verify_credentials!" do
    it "returns true when the discovery chain succeeds" do
      stub_success_chain

      expect(described_class.verify_credentials!("test@icloud.com", "app-specific-pw")).to be(true)
    end

    it "raises AuthenticationError for bad credentials" do
      allow(Net::HTTP).to receive(:start) do |_host, _port, **_opts, &block|
        fake_http = instance_double(Net::HTTP)
        allow(fake_http).to receive(:request).and_return(fake_response(Net::HTTPUnauthorized, ""))
        block.call(fake_http)
      end

      expect { described_class.verify_credentials!("test@icloud.com", "wrong") }.to raise_error(described_class::AuthenticationError)
    end
  end
end
