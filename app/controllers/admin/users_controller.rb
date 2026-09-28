require "csv"

class Admin::UsersController < Admin::BaseController
  ITEMS_PER_PAGE = 20

  def index
    @q = User.ransack(params[:q])
    @signed_up_from = parse_date(params[:signed_up_from])
    @signed_up_to = parse_date(params[:signed_up_to])
    @users = filter_by_signup_date(@q.result).order(created_at: :desc)
    @page = (params[:page] || 1).to_i
    @total_count = @users.count
    @users = @users.offset((@page - 1) * ITEMS_PER_PAGE).limit(ITEMS_PER_PAGE)

    respond_to do |format|
      format.html
      format.csv { send_data generate_csv(filter_by_signup_date(@q.result)), filename: "season-users-#{Time.zone.today}.csv" }
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

  def parse_date(value)
    Date.iso8601(value) if value.present?
  rescue Date::Error
    nil
  end

  # Inclusive on both ends: "to 2026-09-25" includes sign-ups on the 25th.
  def filter_by_signup_date(scope)
    scope = scope.where(created_at: @signed_up_from.beginning_of_day..) if @signed_up_from
    scope = scope.where(created_at: ..@signed_up_to.end_of_day) if @signed_up_to
    scope
  end

  def calculate_avg_cycle_length
    starts = @user.period_starts.ordered.pluck(:started_on)
    return nil if starts.size < 2

    gaps = starts.each_cons(2).map { |a, b| (b - a).to_i }
    (gaps.sum.to_f / gaps.size).round
  end

  def generate_csv(users)
    CSV.generate(headers: true) do |csv|
      csv << ["User ID", "Language", "Onboarding", "Signed Up", "Streak", "Secret Tester"]
      users.each do |u|
        csv << [
          u.public_id,
          u.language || "en",
          u.onboarding_completed? ? "Complete" : "Pending",
          u.created_at.strftime("%Y-%m-%d"),
          u.streak&.current_streak || 0,
          u.secret_tester? ? "Yes" : "No"
        ]
      end
    end
  end

  def user_params
    params.expect(user: [:admin, :secret_tester])
  end
end
