class Customer::DashboardsController < Customer::BaseController
  def index
    @orders = current_user.orders.order(created_at: :desc).limit(5)
    @total_orders = current_user.orders.count
    @pending_orders = current_user.orders.where(status: "pending").count
    @delivered_orders = current_user.orders.where(status: "delivered").count
  end
end
