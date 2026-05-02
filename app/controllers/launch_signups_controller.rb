class LaunchSignupsController < ApplicationController
  allow_unauthenticated_access

  EMAIL_FORMAT = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  rate_limit to: 5, within: 1.hour, only: :create, with: -> { rate_limited }

  def create
    email = params[:email]&.downcase&.strip

    if email.blank?
      render json: {error: "Email is required"}, status: :unprocessable_content
    elsif !EMAIL_FORMAT.match?(email)
      render json: {error: "Please enter a valid email"}, status: :unprocessable_content
    else
      LaunchSignup.find_or_create_by!(email: email)
      render json: {message: "You're on the list! We'll notify you on April 30th."}
    end
  end

  private

  def rate_limited
    render json: {error: "Too many requests. Please try again later."}, status: :too_many_requests
  end
end
