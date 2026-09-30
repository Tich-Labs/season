class Admin::BetaTesterSettingController < Admin::BaseController
  def edit
    @setting = BetaTesterSetting.current
  end

  def update
    @setting = BetaTesterSetting.current
    if @setting.update(setting_params)
      redirect_to admin_beta_testers_path, notice: t(".updated")
    else
      flash.now[:alert] = @setting.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_content
    end
  end

  private

  def setting_params
    params.expect(beta_tester_setting: [:consent_label, :consent_link_text, :consent_url])
  end
end
