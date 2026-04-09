class LaunchSignupsController < ApplicationController
  allow_unauthenticated_access

  def create
    email = params[:email]&.downcase&.strip

    if email.blank?
      render json: {error: "Email is required"}, status: :unprocessable_content
      return
    end

    unless /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.match?(email)
      render json: {error: "Please enter a valid email"}, status: :unprocessable_content
      return
    end

    LaunchSignup.find_or_create_by!(email: email)

    render json: {message: "You're on the list! We'll notify you on April 14th."}
  end
end
