class Vendor::DashboardsController < Vendor::BaseController
  before_action :authenticate_user!

  def index
    @total_orders = current_user.assigned_orders.count
    @pending_orders = current_user.assigned_orders.where(status: %w[confirmed processing]).count
    @delivered_orders = current_user.assigned_orders.where(status: "delivered").count
    @todays_orders = current_user.assigned_orders.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day).count
    @recent_orders = current_user.assigned_orders.includes(:customer, :order_items).order(created_at: :desc).limit(5)
  end
end
