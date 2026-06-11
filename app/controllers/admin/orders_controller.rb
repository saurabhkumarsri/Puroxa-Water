class Admin::OrdersController < Admin::BaseController
  def index
    @orders = Order.includes(:customer, :vendor, :order_items).order(created_at: :desc)
    @orders = @orders.where(status: params[:status]) if params[:status].present?
  end

  def show
    @order = Order.includes(:order_items, :customer, :vendor).find(params[:id])
  end

  def update_status
    @order = Order.find(params[:id])
    if @order.update(status: params[:status])
      # Send notification to customer
      Notification.create!(
        customer: @order.customer,
        order: @order,
        title: "Order ##{@order.id} #{params[:status].titleize}",
        body: "Your order has been #{params[:status]}."
      )
      redirect_to admin_orders_path, notice: "Order status updated to #{params[:status]}."
    else
      redirect_to admin_orders_path, alert: "Failed to update order status."
    end
  end

  def assign_vendor
    @order = Order.find(params[:id])
    @order.update!(vendor_id: params[:vendor_id], status: "confirmed")

    # Notify the customer that their order has been confirmed and a vendor assigned
    Notification.create!(
      customer: @order.customer,
      order: @order,
      title: "Order ##{@order.id} Confirmed",
      body: "Your order has been confirmed and assigned to #{@order.vendor&.display_name || 'a vendor'}."
    )

    # Notify the newly assigned vendor about the order
    if @order.vendor_id.present?
      Notification.create!(
        customer_id: @order.vendor_id,
        order: @order,
        title: "New Order ##{@order.id} assigned to you",
        body: "From #{@order.customer.display_name} · Total ₹#{@order.total_amount}"
      )
    end

    redirect_to admin_orders_path, notice: "Vendor assigned successfully."
  end
end
