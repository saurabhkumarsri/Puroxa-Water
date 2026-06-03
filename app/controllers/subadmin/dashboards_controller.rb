class Subadmin::DashboardsController < Subadmin::BaseController
  def index
    @total_customers = User.where(role: User::ROLES[:customer]).count
    @total_orders = Order.count
    @pending_orders = Order.pending.count
    @todays_orders = Order.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day).count
    @recent_orders = Order.includes(:customer, :order_items).order(created_at: :desc).limit(10)
  end
end
