# Best-effort push of a Season-created/edited/deleted appointment to the
# user's connected Google Calendar -- the other half of "Sync now" (which
# only pulls Google -> Season, see SettingsController#sync_google_calendar).
# Enqueued from CalendarEventsController#create/#update/#destroy.
#
# Runs in the background deliberately: a Google-side failure (revoked
# token, rate limit, network/SSL hiccup) must never block or roll back
# saving the appointment in Season, and Google's API round trip shouldn't
# add latency to that request.
class GoogleCalendarPushJob < ApplicationJob
  queue_as :default

  def perform(action, user_id:, calendar_event_id: nil, google_event_id: nil)
    user = User.find_by(id: user_id)
    return unless user&.google_calendar_connected?

    service = GoogleCalendarService.new(user)

    case action.to_s
    when "create" then push_create(service, calendar_event_id)
    when "update" then push_update(service, calendar_event_id)
    when "delete" then service.delete_event(google_event_id) if google_event_id.present?
    end
  rescue => e
    Rails.logger.error("[GoogleCalendarPushJob] #{action} failed for user #{user_id}: #{e.class}: #{e.message}")
  end

  private

  def push_create(service, calendar_event_id)
    event = CalendarEvent.find_by(id: calendar_event_id)
    return unless event && event.google_event_id.blank?

    created = service.create_event(**attrs_for(event))
    event.update!(google_event_id: created.id) if created&.id
  end

  def push_update(service, calendar_event_id)
    event = CalendarEvent.find_by(id: calendar_event_id)
    return unless event

    if event.google_event_id.present?
      service.update_event(event.google_event_id, **attrs_for(event))
    else
      # Edited an event that was never pushed (e.g. Google Calendar was
      # connected after this event was created) -- create it now instead
      # of silently dropping the change.
      created = service.create_event(**attrs_for(event))
      event.update!(google_event_id: created.id) if created&.id
    end
  end

  def attrs_for(event)
    {
      summary: event.title,
      start_time: event.starts_at,
      end_time: event.ends_at,
      description: event.notes,
      location: event.location
    }
  end
end
