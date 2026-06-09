class Vendor::ReportsController < Vendor::BaseController
  before_action :authenticate_user!

  def daily_collection
    @date = parse_date(params[:date], Date.current)
    @orders = Order.where(paid_at: @date.beginning_of_day..@date.end_of_day, payment_status: "paid")
    @cash_total = @orders.where(payment_mode: "cash").sum(:total_amount)
    @online_total = @orders.where(payment_mode: "online").sum(:total_amount)
    @total_collected = @orders.sum(:total_amount)
    @order_count = @orders.count
  end

  private

  def parse_date(param, default)
    param.present? ? Date.parse(param) : default
  rescue Date::Error
    default
  end
end
