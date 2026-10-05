class Admin::InboxController < Admin::BaseController
  def overview
    @messages = Feedback.active.order(created_at: :desc).limit(50)
    render "admin/inbox/index"
  end

  def feedback
    @messages = Feedback.active.feedback_type_feedback.order(created_at: :desc).limit(50)
    render "admin/inbox/index"
  end

  def bugs
    @messages = Feedback.active.feedback_type_bug_report.order(created_at: :desc).limit(50)
    render "admin/inbox/index"
  end

  def support
    @messages = Feedback.active.feedback_type_support.order(created_at: :desc).limit(50)
    render "admin/inbox/index"
  end

  def archived
    @messages = Feedback.archived.includes(:user, :archived_by).order(archived_at: :desc).limit(50)
    render "admin/inbox/index"
  end

  def show
    @message = Feedback.includes(:user).find(params[:id])
    render "admin/inbox/show"
  end

  def archive
    Feedback.find(params[:id]).archive!(by: current_user)
    redirect_back_or_to admin_inbox_path, notice: "Message archived." # rubocop:disable Rails/I18nLocaleTexts
  end

  def unarchive
    Feedback.find(params[:id]).unarchive!
    redirect_back_or_to admin_inbox_archived_path, notice: "Message restored to the inbox." # rubocop:disable Rails/I18nLocaleTexts
  end

  # Bulk-archives every open message of the current inbox view created before the given date.
  def archive_before
    cutoff = Date.iso8601(params[:before].to_s)
    scope = inbox_scope(params[:filter]).where(created_at: ...cutoff.beginning_of_day)
    count = scope.update_all(active: false, archived_at: Time.current, archived_by_id: current_user.id, updated_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
    redirect_back_or_to admin_inbox_path, notice: "Archived #{count} #{"message".pluralize(count)} created before #{cutoff.strftime("%-d %b %Y")}." # rubocop:disable Rails/I18nLocaleTexts
  rescue Date::Error
    redirect_back_or_to admin_inbox_path, alert: "Pick a valid date to archive before." # rubocop:disable Rails/I18nLocaleTexts
  end

  def export_csv
    messages = inbox_scope(params[:filter])

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["Date", "User ID", "Type", "Message"]
      messages.includes(:user).order(created_at: :desc).each do |f|
        csv << [f.created_at.strftime("%Y-%m-%d"), f.user.public_id, f.type, f.message.to_s.truncate(100)]
      end
    end

    respond_to do |format|
      format.csv { send_data csv_data, filename: "inbox_#{params[:filter] || "all"}_#{Time.zone.today}.csv" }
    end
  end

  private

  def inbox_scope(filter)
    case filter
    when "feedback" then Feedback.active.feedback_type_feedback
    when "bugs" then Feedback.active.feedback_type_bug_report
    when "support" then Feedback.active.feedback_type_support
    else Feedback.active
    end
  end
end
