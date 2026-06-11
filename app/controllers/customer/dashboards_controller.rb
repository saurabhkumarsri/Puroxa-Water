class Customer::DashboardsController < Customer::BaseController
  def index
    @orders = current_user.orders.order(created_at: :desc).limit(5)
    @total_orders = current_user.orders.count
    @pending_orders = current_user.orders.where(status: "pending").count
    @delivered_orders = current_user.orders.where(status: "delivered").count
    @pending_amount = current_user.pending_amount

    # Monthly spend data (last 6 months)
    @monthly_spend = []
    5.downto(0) do |i|
      month_start = i.months.ago.beginning_of_month
      month_end = i.months.ago.end_of_month
      total = current_user.orders.where(created_at: month_start..month_end).sum(:total_amount)
      @monthly_spend << {
        label: month_start.strftime("%b %Y"),
        amount: total
      }
    end

    # Notifications
    @notifications = current_user.notifications.recent
    @unread_count = current_user.notifications.unread.count
  end
end
