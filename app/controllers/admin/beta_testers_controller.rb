require "csv"

class Admin::BetaTestersController < Admin::BaseController
  ITEMS_PER_PAGE = 50

  before_action :set_filters

  def index
    scope = filtered_scope
    @total_count = scope.count
    @counts_by_platform = BetaTester.group(:platform).count
    @counts_by_status = BetaTester.group(:status).count
    @current_page = current_page
    @total_pages = [(@total_count.to_f / ITEMS_PER_PAGE).ceil, 1].max
    @beta_testers = scope.newest_first.includes(:user).offset((@current_page - 1) * ITEMS_PER_PAGE).limit(ITEMS_PER_PAGE)
  end

  def show
    @beta_tester = BetaTester.find(params[:id])
  end

  def update
    @beta_tester = BetaTester.find(params[:id])
    if @beta_tester.update(beta_tester_params)
      redirect_to admin_beta_tester_path(@beta_tester), notice: t(".updated")
    else
      redirect_to admin_beta_testers_path, alert: @beta_tester.errors.full_messages.to_sentence
    end
  end

  # Honours whatever filters are currently applied on the index, so
  # "Export CSV" exports what the admin is actually looking at.
  # Honours the same filters as #index, so the CSV link on a filtered page
  # exports that page's rows rather than the whole table.
  def export_csv
    testers = filtered_scope.newest_first

    csv_data = CSV.generate(headers: true) do |csv|
      csv << ["Name", "Email", "Platform", "Status", "Beta Consent", "Registered At"]
      testers.find_each do |t|
        csv << [
          t.name,
          t.email,
          t.platform,
          t.status,
          t.beta_consent? ? "Yes" : "No",
          t.created_at.strftime("%Y-%m-%d %H:%M")
        ]
      end
    end

    send_data csv_data, filename: "beta_testers_#{Time.zone.today}.csv", type: "text/csv"
  end

  private

  # Shared by index and export_csv so the CSV always matches the filters the
  # admin currently has applied. Unknown values fall back to nil (= no filter)
  # rather than silently returning an empty list.
  def set_filters
    @platform = BetaTester::PLATFORMS.include?(params[:platform]) ? params[:platform] : nil
    @status = BetaTester::STATUSES.include?(params[:status]) ? params[:status] : nil
    @q = params[:q].to_s.strip
  end

  def filtered_scope
    scope = BetaTester.all
    scope = scope.for_platform(@platform) if @platform
    scope = scope.with_status(@status) if @status
    scope = scope.search(@q) if @q.present?
    scope
  end

  def current_page
    [params.fetch(:page, 1).to_i, 1].max
  end

  def beta_tester_params
    params.expect(beta_tester: [:status])
  end
end
