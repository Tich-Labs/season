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
    @period_dates = @user.period_starts.ordered.pluck(:started_on)
    @avg_cycle_length = calculate_avg_cycle_length
    @next_period = if @user.last_period_start || @user.period_starts.any?
      CycleCalculatorService.new(@user).next_period_start
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_back_or_to(admin_users_path, notice: "User updated.") # rubocop:disable Rails/I18nLocaleTexts
    else
      redirect_back_or_to(admin_users_path, alert: @user.errors.full_messages.to_sentence)
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy!
    redirect_to admin_users_path, notice: "User deleted." # rubocop:disable Rails/I18nLocaleTexts
  end

  private

  def calculate_avg_cycle_length
    starts = @user.period_starts.ordered.pluck(:started_on)
    return nil if starts.size < 2

    gaps = starts.each_cons(2).map { |a, b| (b - a).to_i }
    (gaps.sum.to_f / gaps.size).round
  end

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

  def user_params
    params.expect(user: [:admin])
  end
end
