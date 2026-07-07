# frozen_string_literal: true

# Recalculates dashboard stats for calendar months touched by the given dates.
class Stats::RecalculateServer
  def initialize(user, dates)
    @user = user
    @dates = Array(dates).map(&:to_date).uniq
  end

  def call
    return if dates.empty?

    dates.map { |date| [date.year, date.month] }.uniq.each do |year, month|
      Stats::CalculateMonth.new(user.id, year, month).call
    end
  end

  private

  attr_reader :user, :dates
end
