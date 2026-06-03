class Admin::DashboardsController < Admin::BaseController
  def index
    @total_customers = User.where(role: User::ROLES[:customer]).count
    @total_vendors = User.where(role: User::ROLES[:vendor]).count
    @total_orders = Order.count
    @pending_orders = Order.pending.count
    @todays_revenue = Order.delivered.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day).sum(:total_amount)
    @monthly_revenue = Order.delivered.this_month.sum(:total_amount)
    @recent_orders = Order.includes(:customer, :order_items).order(created_at: :desc).limit(10)
  end
end
