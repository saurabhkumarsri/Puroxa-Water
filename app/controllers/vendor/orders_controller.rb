class Vendor::OrdersController < Vendor::BaseController
  before_action :authenticate_user!

  def index
    @orders = Order.where(vendor_id: current_user.id).includes(:customer, :order_items).order(created_at: :desc)
    @orders = @orders.where(status: params[:status]) if params[:status].present?
  end

  def show
    @order = Order.where(vendor_id: current_user.id).includes(:order_items, :products, :customer).find(params[:id])
  end

  def update_status
    @order = Order.where(vendor_id: current_user.id).find(params[:id])
    allowed = %w[confirmed processing shipped delivered]
    if allowed.include?(params[:status])
      @order.update!(status: params[:status])
      redirect_to vendor_orders_path, notice: "Order status updated to #{params[:status]}."
    else
      redirect_to vendor_orders_path, alert: "Invalid status transition."
    end
  end
end
