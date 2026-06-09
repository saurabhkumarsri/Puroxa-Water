class Admin::ReportsController < Admin::BaseController
  def daily_sales
    @date = parse_date(params[:date], Date.current)
    @orders = Order.where(created_at: @date.beginning_of_day..@date.end_of_day).where.not(status: "cancelled")
    @total_revenue = @orders.sum(:total_amount)
    @total_orders = @orders.count
  end

  def monthly_sales
    @month = params[:month].present? ? Date.parse("#{params[:month]}-01") : Date.current.beginning_of_month
    @orders = Order.where(created_at: @month.beginning_of_month..@month.end_of_month).where.not(status: "cancelled")
    @total_revenue = @orders.sum(:total_amount)
    @total_orders = @orders.count
    @daily_breakdown = @orders.group("DATE(created_at)").sum(:total_amount)
  end

  def product_wise
    @start_date = parse_date(params[:start_date], Date.current.beginning_of_month)
    @end_date = parse_date(params[:end_date], Date.current.end_of_day)
    @order_items = OrderItem.joins(:order, :product)
                            .where(orders: { created_at: @start_date.beginning_of_day..@end_date.end_of_day })
                            .where.not(orders: { status: "cancelled" })
                            .select("products.name, products.size, products.bottles_per_pack, SUM(order_items.quantity) as total_qty, SUM(order_items.total_price) as total_revenue")
                            .group("products.id, products.name, products.size, products.bottles_per_pack")
                            .order("total_revenue DESC")
  end

  def customer_wise
    @start_date = parse_date(params[:start_date], Date.current.beginning_of_month)
    @end_date = parse_date(params[:end_date], Date.current.end_of_day)
    @customers = User.where(role: User::ROLES[:customer])
                     .left_joins(:orders)
                     .where(orders: { created_at: @start_date.beginning_of_day..@end_date.end_of_day })
                     .where.not(orders: { status: "cancelled" })
                     .select("users.*, COUNT(orders.id) as order_count, SUM(orders.total_amount) as total_spent")
                     .group("users.id")
                     .order("total_spent DESC")
  end

  def daily_collection
    @date = parse_date(params[:date], Date.current)
    @orders = Order.where(paid_at: @date.beginning_of_day..@date.end_of_day, payment_status: "paid")
    @cash_total = @orders.where(payment_mode: "cash").sum(:total_amount)
    @online_total = @orders.where(payment_mode: "online").sum(:total_amount)
    @total_collected = @orders.sum(:total_amount)
    @vendor_summary = @orders.joins(:vendor).group("users.id", "users.first_name").select("users.id, users.first_name, SUM(orders.total_amount) as total, COUNT(orders.id) as count, orders.payment_mode")
  end

  private

  def parse_date(param, default)
    param.present? ? Date.parse(param) : default
  rescue Date::Error
    default
  end
end
