class Admin::LaunchSignupsController < Admin::BaseController
  def index
    @signups = LaunchSignup.order(created_at: :desc)
    @total = @signups.count
  end

  def export_csv
    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["Email", "Signed Up"]
      LaunchSignup.order(created_at: :asc).each do |s|
        csv << [s.email, s.created_at.strftime("%Y-%m-%d %H:%M")]
      end
    end

    respond_to do |format|
      format.csv { send_data csv_data, filename: "launch_signups_#{Date.today}.csv" }
    end
  end
end
