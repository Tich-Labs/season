module Api
  class HolidaysController < ApplicationController
    allow_unauthenticated_access
    allow_pin_bypass

    def index
      country = params[:country].to_s.strip.downcase

      render(json: {holidays: []}) and return if country.blank?

      year = Date.current.year

      holidays = Holidays.between(Date.new(year, 1, 1), Date.new(year, 12, 31), country.to_sym)
        .map { |h| {date: h[:date].iso8601, name: h[:name]} }

      render json: {holidays: holidays}
    rescue Holidays::InvalidRegion, ArgumentError, NoMethodError
      render json: {holidays: []}
    end
  end
end
