# frozen_string_literal: true

# Public (unauthenticated) account-deletion request. This is the web URL given
# to the Play Store "Account deletion" data-safety form and the App Store:
# anyone can request deletion by email, a signed one-hour link is emailed to
# that address, and only that link can destroy the account and its data.
class AccountDeletionController < ApplicationController
  allow_unauthenticated_access
  layout "beta"

  before_action :set_noindex

  TOKEN_PURPOSE = :account_deletion
  TOKEN_TTL = 1.hour

  def new
    @form = AccountDeletion::RequestForm.new
  end

  def create
    @form = AccountDeletion::RequestForm.new(form_params)

    unless @form.valid?
      flash.now[:alert] = t("account_deletion.new.invalid_email")
      return render :new, status: :unprocessable_content
    end

    user = User.find_by("LOWER(email) = ?", @form.normalized_email)

    # Always say "check your inbox" so this endpoint can't be used to probe
    # whether an email has an account. Only send the link when one exists.
    AccountDeletionMailer.confirmation(user, deletion_token(user)).deliver_later if user

    redirect_to account_deletion_sent_path
  end

  def sent
  end

  def confirm
    user = User.find_signed(params[:token], purpose: TOKEN_PURPOSE)
    @deleted = false
    return unless user

    user.avatar.purge if user.avatar.attached?
    user.destroy!
    @deleted = true
  end

  private

  def form_params
    params.expect(account_deletion: [:email])
  end

  def deletion_token(user)
    user.signed_id(purpose: TOKEN_PURPOSE, expires_in: TOKEN_TTL)
  end
end
