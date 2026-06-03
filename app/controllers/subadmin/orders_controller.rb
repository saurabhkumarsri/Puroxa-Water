class Subadmin::OrdersController < Subadmin::BaseController
  def index
    @orders = Order.includes(:customer, :vendor, :order_items).order(created_at: :desc)
    @orders = @orders.where(status: params[:status]) if params[:status].present?
  end

  def show
    @order = Order.includes(:order_items, :customer, :vendor).find(params[:id])
    @vendors = User.where(role: User::ROLES[:vendor]).includes(:vendor_profile)
  end

  def update_status
    @order = Order.find(params[:id])
    if @order.update(status: params[:status])
      redirect_to subadmin_orders_path, notice: "Order status updated to #{params[:status]}."
    else
      redirect_to subadmin_orders_path, alert: "Failed to update order status."
    end
  end

  def assign_vendor
    @order = Order.find(params[:id])
    @order.update!(vendor_id: params[:vendor_id], status: "confirmed")
    redirect_to subadmin_orders_path, notice: "Vendor assigned successfully."
  end
end
