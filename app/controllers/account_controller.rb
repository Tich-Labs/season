class AccountController < ApplicationController
  layout "application"
  before_action :authenticate_user

  def show
    @user = current_user
  end

  def export
    @user = current_user

    # Build comprehensive user data export (GDPR Article 20)
    export_data = {
      export_date: Time.zone.now.iso8601,
      user: {
        id: @user.id,
        email: @user.email,
        first_name: @user.first_name,
        last_name: @user.last_name,
        language: @user.language,
        created_at: @user.created_at&.iso8601,
        last_period_start: @user.last_period_start&.iso8601,
        cycle_length: @user.cycle_length,
        onboarding_completed: @user.onboarding_completed?
      },
      cycle_data: @user.cycle_entries.map { |entry|
        {
          id: entry.id,
          date: entry.date&.iso8601,
          flow_type: entry.flow_type,
          flow_intensity: entry.flow_intensity,
          created_at: entry.created_at&.iso8601,
          updated_at: entry.updated_at&.iso8601
        }
      },
      symptom_logs: @user.symptom_logs.map { |log|
        {
          id: log.id,
          date: log.date&.iso8601,
          mood: log.mood,
          energy: log.energy,
          sleep: log.sleep,
          pain: log.pain,
          physical: log.physical,
          cravings: log.cravings,
          mental: log.mental,
          discharge: log.discharge,
          sexual_intercourse: log.sexual_intercourse?,
          temperature: log.temperature,
          weight: log.weight,
          notes: log.notes,
          created_at: log.created_at&.iso8601,
          updated_at: log.updated_at&.iso8601
        }
      },
      calendar_events: @user.calendar_events.map { |event|
        {
          id: event.id,
          title: event.title,
          start_time: event.start_time&.iso8601,
          end_time: event.end_time&.iso8601,
          category: event.category,
          notes: event.notes,
          created_at: event.created_at&.iso8601,
          updated_at: event.updated_at&.iso8601
        }
      },
      superpower_logs: @user.superpower_logs.map { |log|
        {
          id: log.id,
          date: log.date&.iso8601,
          superpower_id: log.superpower_id,
          rating: log.rating,
          notes: log.notes,
          created_at: log.created_at&.iso8601,
          updated_at: log.updated_at&.iso8601
        }
      },
      reminders: @user.reminders.map { |reminder|
        {
          id: reminder.id,
          reminder_type: reminder.reminder_type,
          enabled: reminder.enabled,
          time: reminder.time&.strftime("%H:%M"),
          frequency: reminder.frequency,
          created_at: reminder.created_at&.iso8601,
          updated_at: reminder.updated_at&.iso8601
        }
      },
      consents: @user.user_consents.map { |consent|
        {
          id: consent.id,
          consent_type: consent.consent_type,
          granted_at: consent.granted_at&.iso8601,
          revoked_at: consent.revoked_at&.iso8601,
          ip_address: consent.ip_address,
          user_agent: consent.user_agent
        }
      }
    }

    # Generate filename with timestamp
    filename = "season-export-#{@user.id}-#{Time.zone.now.strftime("%Y%m%d-%H%M%S")}.json"

    respond_to do |format|
      format.json {
        send_data export_data.to_json(pretty: true),
          filename: filename,
          type: "application/json; charset=utf-8",
          disposition: "attachment"
      }
    end
  end

  def destroy
    @user = current_user

    # Destroy all associated data (dependent: :destroy already configured in User model)
    # This deletes: cycle_entries, calendar_events, symptom_logs, superpower_logs,
    # reminders, feedbacks, streak, avatar
    @user.destroy!

    # Also purge any ActiveStorage attachments
    @user.avatar&.purge

    # Log out the user
    logout

    redirect_to root_path, notice: t(".account_deleted")
  end
end
