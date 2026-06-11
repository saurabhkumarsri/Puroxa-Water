class Customer::OrdersController < Customer::BaseController
  def index
    @orders = current_user.orders.includes(:order_items, :products).order(created_at: :desc)
  end

  def show
    @order = current_user.orders.includes(:order_items, :products).find(params[:id])
  end

  def new
    @products = Product.active.order(:name)
    @addresses = current_user.addresses
  end

  def create
    result = Orders::CreateService.new(current_user, order_params).call
    if result.success?
      order = result.order

      if order.vendor_id.present?
        # Specific vendor was already assigned — notify them directly.
        Notification.create!(
          customer_id: order.vendor_id,
          order: order,
          title: "New Order ##{order.id} from #{order.customer.display_name}",
          body: "Total ₹#{order.total_amount} · #{order.payment_mode.to_s.titleize} · #{order.order_items.sum(:quantity)} pack(s)"
        )
      else
        # No vendor assigned yet — fan the order out to every approved
        # vendor so any of them can pick it up. Skip if there are none.
        approved_vendor_user_ids = Vendor.where(approved: true).pluck(:user_id)
        approved_vendor_user_ids.each do |vendor_user_id|
          Notification.create!(
            customer_id: vendor_user_id,
            order: order,
            title: "New Order ##{order.id} from #{order.customer.display_name}",
            body: "Total ₹#{order.total_amount} · #{order.payment_mode.to_s.titleize} · #{order.order_items.sum(:quantity)} pack(s) · unassigned"
          )
        end
      end

      # Notify all admins about the new order
      User.where(role: User::ROLES[:admin]).find_each do |admin|
        Notification.create!(
          customer_id: admin.id,
          order: order,
          title: "New Order ##{order.id} from #{order.customer.display_name}",
          body: "Total ₹#{order.total_amount} · assigned to #{order.vendor&.display_name || 'unassigned'}"
        )
      end

      redirect_to customer_orders_path, notice: "Order placed successfully!"
    else
      flash.now[:alert] = result.errors.join(", ")
      @products = Product.active.order(:name)
      @addresses = current_user.addresses
      render :new, status: :unprocessable_entity
    end
  end

  def cancel
    @order = current_user.orders.find(params[:id])
    if @order.pending?
      @order.update!(status: "cancelled")
      redirect_to customer_orders_path, notice: "Order cancelled successfully."
    else
      redirect_to customer_orders_path, alert: "Cannot cancel order that is already #{@order.status}."
    end
  end

  def pay
    @order = current_user.orders.includes(:order_items, :products).find(params[:id])

    if @order.payment_status == "paid"
      redirect_to customer_order_path(@order), alert: "This order is already paid."
      return
    end

    amount   = @order.total_with_online_discount.to_s
    txn_note = "Order #{@order.id} - #{MERCHANT_NAME}"
    pn       = MERCHANT_NAME.gsub(" ", "+")

    @upi_links = {
      phonepe: "phonepe://pay?pa=#{MERCHANT_UPI_IDS[:phonepe]}&pn=#{pn}&am=#{amount}&cu=INR&tn=#{URI.encode_www_form_component(txn_note)}",
      gpay:    "tez://upi/pay?pa=#{MERCHANT_UPI_IDS[:gpay]}&pn=#{pn}&am=#{amount}&cu=INR&tn=#{URI.encode_www_form_component(txn_note)}",
      paytm:   "paytmmp://pay?pa=#{MERCHANT_UPI_IDS[:paytm]}&pn=#{pn}&am=#{amount}&cu=INR&tn=#{URI.encode_www_form_component(txn_note)}",
      generic: "upi://pay?pa=#{MERCHANT_UPI_IDS[:paytm]}&pn=#{pn}&am=#{amount}&cu=INR&tn=#{URI.encode_www_form_component(txn_note)}"
    }
  end

  private

  def order_params
    params.permit(:delivery_address, :notes, :discount_code, :payment_mode, order_items: [:product_id, :quantity])
  end
end
