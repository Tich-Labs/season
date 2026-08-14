class Admin::M1ChecklistController < Admin::BaseController
  ITEM_KEYS = %w[
    loader_app loader_splash
    auth_welcome auth_signup auth_confirmation auth_login auth_google auth_facebook auth_apple
    pw_recover pw_reset pw_done pw_already_reset pw_inbox_full pw_wrong_email pw_contact
    invite_valid invite_used launch_page terms privacy
    ob_step1 ob_step2 ob_step3 ob_step4 ob_step5_picker ob_step5_modal ob_step5_auto
    ob_step6 ob_step7 ob_step8 ob_step9 ob_step10 ob_finish ob_back
    cc_german cc_validation cc_ios_forms cc_session
  ].freeze

  def show
    @checks_by_item = M1ChecklistCheck.includes(:user).group_by(&:item_key)
    @my_checked = M1ChecklistCheck.where(user: current_user).pluck(:item_key)
    @total = ITEM_KEYS.size
    @done = @my_checked.size
    @done_pct = @total.zero? ? 0 : (@done * 100 / @total)
    @team_done = M1ChecklistCheck.distinct.count(:item_key)
    @tester_count = M1ChecklistCheck.distinct.count(:user_id)
  end

  def toggle
    item_key = params[:item_key].to_s
    unless ITEM_KEYS.include?(item_key)
      return render json: {ok: false, error: "unknown item"}, status: :unprocessable_content
    end

    checked = ActiveModel::Type::Boolean.new.cast(params[:checked])
    check = M1ChecklistCheck.find_or_initialize_by(user: current_user, item_key: item_key)
    if checked
      check.checked_at = Time.current
      check.save!
    else
      check.destroy!
    end

    render json: {
      ok: true,
      checked: checked,
      done: M1ChecklistCheck.where(user: current_user).count,
      total: ITEM_KEYS.size
    }
  end

  def reset
    M1ChecklistCheck.where(user: current_user).delete_all
    render json: {ok: true}
  end
end
