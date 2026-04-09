require "csv"

class Admin::UsersController < Admin::BaseController
  ITEMS_PER_PAGE = 20

  def index
    @q = User.ransack(params[:q])
    @users = @q.result.order(created_at: :desc)
    @page = (params[:page] || 1).to_i
    @total_count = @users.count
    @users = @users.offset((@page - 1) * ITEMS_PER_PAGE).limit(ITEMS_PER_PAGE)

    respond_to do |format|
      format.html
      format.csv { send_data generate_csv(@q.result), filename: "season-users-#{Time.zone.today}.csv" }
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
