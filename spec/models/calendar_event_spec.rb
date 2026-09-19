require "rails_helper"

RSpec.describe CalendarEvent, type: :model do
  describe "#starts_at / #ends_at" do
    it "combines the date column with the time-of-day column" do
      event = build(:calendar_event, date: Date.new(2026, 6, 15), start_time: "09:30", end_time: "10:45")

      expect(event.starts_at).to eq(Time.zone.local(2026, 6, 15, 9, 30))
      expect(event.ends_at).to eq(Time.zone.local(2026, 6, 15, 10, 45))
    end

    it "uses end_date for a multi-day event's end time" do
      event = build(:calendar_event, date: Date.new(2026, 6, 15), end_date: Date.new(2026, 6, 17), start_time: "09:00", end_time: "17:00")

      expect(event.ends_at).to eq(Time.zone.local(2026, 6, 17, 17, 0))
    end

    it "falls back to midnight when no time is set" do
      event = build(:calendar_event, date: Date.new(2026, 6, 15), start_time: nil, end_time: nil)

      expect(event.starts_at).to eq(Date.new(2026, 6, 15).to_time)
    end
  end
end
