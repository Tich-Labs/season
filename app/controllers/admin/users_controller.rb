require "csv"

class Admin::UsersController < Admin::BaseController
  include Pagy::Backend

  def index
    @q = User.ransack(params[:q])
    @pagy, @users = pagy(@q.result.order(created_at: :desc))

    respond_to do |format|
      format.html
      format.csv { send_data generate_csv(@q.result), filename: "season-users-#{Date.today}.csv" }
    end
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def generate_csv(users)
    CSV.generate(headers: true) do |csv|
      csv << ["Name", "Email", "Language", "Onboarding", "Signed Up", "Streak"]
      users.each do |u|
        csv << [
          u.name || "",
          u.email,
          u.language || "en",
          u.onboarding_completed? ? "Complete" : "Pending",
          u.created_at.strftime("%Y-%m-%d"),
          u.streak&.current_streak || 0
        ]
      end
    end
  end
end
