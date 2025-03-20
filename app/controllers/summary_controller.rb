# Controller for summary actions
class SummaryController < ApplicationController
  before_action :authenticate_request, only: %i[index]

  def index
    render_success({
                     overview: calculate_overview,
                     trends: calculate_trends,
                     categories: calculate_categories,
                     payment_methods: calculate_payment_methods,
                     locations: calculate_locations,
                     recent_expenditures: fetch_recent_expenditures
                   })
  end

  private

  def total_amount
    @total_amount ||= @user.expenditures.sum(:amount).to_f
  end

  def year_summary
    @year_summary ||= current_year_expenditures
                      .select(
                        "COUNT(*) as total_items",
                        "COALESCE(SUM(amount), 0) as total_amount",
                        "COALESCE(AVG(amount), 0) as avg_amount",
                        "COALESCE(MAX(amount), 0) as max_amount",
                        "COALESCE(MIN(amount), 0) as min_amount"
                      )
                      .first
  end

  def current_year_expenditures
    @current_year_expenditures ||= @user.expenditures.where(date: 1.year.ago..)
  end

  def previous_month_expenditures
    @previous_month_expenditures ||= @user.expenditures.where(date: 2.months.ago.all_month)
  end

  def current_month_expenditures
    @current_month_expenditures ||= @user.expenditures.where(date: 1.month.ago.all_month)
  end

  def calculate_overview
    previous_month_total = previous_month_expenditures.sum(:amount)
    current_month_total = current_month_expenditures.sum(:amount)
    monthly_change = current_month_total - previous_month_total
    monthly_change_percentage = if previous_month_total.zero?
                                  0
                                else
                                  (monthly_change.to_f / previous_month_total * 100).round(2)
                                end

    {
      totalItems: year_summary.total_items,
      totalAmount: year_summary.total_amount.to_i,
      averageAmount: year_summary.avg_amount.to_i,
      largestAmount: year_summary.max_amount.to_i,
      smallestAmount: year_summary.min_amount.to_i,
      monthlyChange: monthly_change.to_i,
      monthlyChangePercentage: monthly_change_percentage
    }
  end

  def calculate_trends
    {
      monthly: calculate_monthly_trends,
      weekly: calculate_weekly_trends
    }
  end

  def calculate_monthly_trends
    months = Array.new(4) do |i|
      date = Date.current.beginning_of_month - i.months
      [date.strftime("%Y-%m"), date.beginning_of_month, date.end_of_month]
    end

    results = months.map do |month_str, start_date, end_date|
      total = @user.expenditures
                   .where(date: start_date..end_date)
                   .select("COALESCE(SUM(amount), 0) as total, COUNT(*) as count")
                   .first
      {
        date: month_str,
        amount: total.total.to_i,
        count: total.count
      }
    end

    results.reverse
  end

  def calculate_weekly_trends
    weeks = Array.new(4) do |i|
      end_date = Date.current.end_of_week - (i * 7).days
      start_date = end_date.beginning_of_week
      [end_date.strftime("%Y-%m-%d"), start_date, end_date]
    end

    results = weeks.map do |week_str, start_date, end_date|
      total = @user.expenditures
                   .where(date: start_date..end_date)
                   .select("COALESCE(SUM(amount), 0) as total, COUNT(*) as count")
                   .first
      {
        date: week_str,
        amount: total.total.to_i,
        count: total.count
      }
    end

    results.reverse
  end

  def calculate_categories
    return [] if total_amount.zero?

    @calculate_categories ||= @user.categories
                                   .left_joins(:expenditures)
                                   .group("categories.id", "categories.name", "categories.color")
                                   .select(
                                     "categories.id",
                                     "categories.name",
                                     "categories.color",
                                     "COALESCE(CAST(SUM(expenditures.amount) AS float), 0) as total_amount",
                                     "COUNT(expenditures.id) as count"
                                   )
                                   .having("COUNT(expenditures.id) > 0")
                                   .order("total_amount DESC")
                                   .limit(5)
                                   .map do |category|
      {
        id: category.id,
        name: category.name,
        amount: category.total_amount.to_i,
        count: category.count,
        percentage: ((category.total_amount / total_amount) * 100).round(2),
        color: category.color
      }
    end
  end

  def calculate_payment_methods
    return [] if total_amount.zero?

    @calculate_payment_methods ||= @user.payment_methods
                                        .left_joins(:expenditures)
                                        .group(
                                          "payment_methods.id",
                                          "payment_methods.name",
                                          "payment_methods.payment_type"
                                        )
                                        .select(
                                          "payment_methods.id",
                                          "payment_methods.name",
                                          "payment_methods.payment_type",
                                          "COALESCE(CAST(SUM(expenditures.amount) AS float), 0) as total_amount",
                                          "COUNT(expenditures.id) as count"
                                        )
                                        .having("COUNT(expenditures.id) > 0")
                                        .order("total_amount DESC")
                                        .limit(5)
                                        .map do |payment|
      {
        id: payment.id,
        name: payment.name,
        amount: payment.total_amount.to_i,
        count: payment.count,
        percentage: ((payment.total_amount / total_amount) * 100).round(2),
        payment_type: payment.payment_type
      }
    end
  end

  def calculate_locations
    return [] if total_amount.zero?

    @calculate_locations ||= @user.locations
                                  .left_joins(:expenditures)
                                  .group("locations.id", "locations.name")
                                  .select(
                                    "locations.id",
                                    "locations.name",
                                    "COALESCE(CAST(SUM(expenditures.amount) AS float), 0) as total_amount",
                                    "COUNT(expenditures.id) as count"
                                  )
                                  .having("COUNT(expenditures.id) > 0")
                                  .order("total_amount DESC")
                                  .limit(5)
                                  .map do |location|
      {
        id: location.id,
        name: location.name,
        amount: location.total_amount.to_i,
        count: location.count,
        percentage: ((location.total_amount / total_amount) * 100).round(2)
      }
    end
  end

  def fetch_recent_expenditures
    @user.expenditures
         .includes(:category, :location, :payment_method)
         .order(date: :desc)
         .limit(3)
         .map do |expenditure|
      {
        id: expenditure.id,
        date: expenditure.date.strftime("%Y-%m-%d"),
        amount: expenditure.amount.to_i,
        description: expenditure.description,
        category: expenditure.category&.then do |c|
          {
            name: c.name,
            color: c.color
          }
        end,
        location: expenditure.location&.then do |l|
          {
            name: l.name
          }
        end,
        payment: expenditure.payment_method&.then do |p|
          {
            name: p.name,
            payment_type: p.payment_type
          }
        end
      }.compact
    end
  end
end
