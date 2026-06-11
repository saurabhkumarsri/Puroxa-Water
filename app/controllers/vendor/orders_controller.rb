class Vendor::OrdersController < Vendor::BaseController
  before_action :authenticate_user!

  def index
    base_orders = Order.includes(:customer, :vendor, :order_items).order(created_at: :desc)

    @active_count     = base_orders.where(status: %w[pending confirmed processing shipped]).count
    @delivered_count  = base_orders.where(status: "delivered").count
    @cancelled_count  = base_orders.where(status: "cancelled").count
    @all_count        = base_orders.count

    @orders = case params[:tab]
              when "delivered"
                base_orders.where(status: "delivered")
              when "cancelled"
                base_orders.where(status: "cancelled")
              when "all"
                base_orders
              else
                base_orders.where(status: %w[pending confirmed processing shipped])
              end
  end

  def show
    @order = Order.includes(:order_items, :products, :customer, :vendor).find(params[:id])
    @customer_orders = Order.where(customer_id: @order.customer_id).where.not(id: @order.id).order(created_at: :desc).limit(10)
  end

  def new
    @products = Product.active.order(:name)
    @customers = User.where(role: User::ROLES[:customer]).order(:first_name)
  end

  def create
    customer = User.find(params[:customer_id])
    result = Orders::CreateService.new(customer, order_params).call
    if result.success?
      order = result.order
      order.update!(vendor: current_user)

      # Notify the customer that the vendor placed an order on their behalf
      Notification.create!(
        customer: customer,
        order: order,
        title: "Order ##{order.id} Placed by #{current_user.display_name}",
        body: "Your order has been placed. Total: ₹#{order.total_amount}."
      )

      # Notify all admins about the new order
      User.where(role: User::ROLES[:admin]).find_each do |admin|
        Notification.create!(
          customer_id: admin.id,
          order: order,
          title: "New Order ##{order.id} from #{customer.display_name} (by vendor #{current_user.display_name})",
          body: "Total ₹#{order.total_amount} · assigned to #{current_user.display_name}"
        )
      end

      redirect_to vendor_orders_path, notice: "Order created successfully for #{customer.display_name}!"
    else
      flash.now[:alert] = result.errors.join(", ")
      @products = Product.active.order(:name)
      @customers = User.where(role: User::ROLES[:customer]).order(:first_name)
      render :new, status: :unprocessable_entity
    end
  end

  def new_orders
    @orders = Order.includes(:customer, :order_items)
                   .where.not(status: 'delivered')
                   .where.not(payment_status: 'paid')
                   .order(created_at: :desc)
  end

  def update_status
    @order = Order.find(params[:id])
    allowed = %w[confirmed processing shipped delivered]
    if allowed.include?(params[:status])
      @order.update!(status: params[:status])

      # Custom message for 'confirmed' (Order Received)
      if params[:status] == "confirmed"
        title = "Order ##{@order.id} Received"
        body = "Your Order request has been received by Puroxa Water."
      else
        title = "Order ##{@order.id} #{params[:status].titleize}"
        body = "Your order has been #{params[:status]} by Puroxa Water."
      end

      Notification.create!(
        customer: @order.customer,
        order: @order,
        title: title,
        body: body
      )

      redirect_back fallback_location: vendor_orders_path, notice: "Order status updated to #{params[:status]}."
    else
      redirect_back fallback_location: vendor_orders_path, alert: "Invalid status transition."
    end
  end

  def collect_cash
    @order = Order.find(params[:id])
    if @order.payment_pending?
      # If vendor collects cash for an order that was originally "online" mode,
      # remove the online discount because cash payment gets no online discount.
      @order.remove_online_discount! if @order.payment_mode == "online"
      finalize_payment_and_deliver!(
        @order,
        notice: "Payment collected successfully! Cash collected — online discount removed."
      )
    else
      redirect_back fallback_location: vendor_order_path(@order), alert: "Payment is already #{@order.payment_status}."
    end
  end

  def confirm_online
    @order = Order.find(params[:id])
    if @order.payment_pending? && @order.payment_mode == "online"
      @order.apply_online_discount!
      finalize_payment_and_deliver!(
        @order,
        notice: "Online payment confirmed. Discount applied."
      )
    else
      redirect_back fallback_location: vendor_order_path(@order), alert: "Cannot confirm online payment for this order."
    end
  end

  private

  # Mark the order as paid and auto-advance to "delivered", then notify the customer.
  # Used by both collect_cash and confirm_online so behaviour stays consistent.
  def finalize_payment_and_deliver!(order, notice:)
    order.update!(payment_status: "paid", paid_at: Time.current)

    # Auto-deliver: once payment is received, treat the order as delivered
    # unless it was already delivered or cancelled.
    if order.status != "delivered" && order.status != "cancelled"
      order.update!(status: "delivered")

      Notification.create!(
        customer: order.customer,
        order: order,
        title: "Order ##{order.id} Delivered",
        body: "Your order has been delivered by Puroxa Water. Thank you!"
      )
    end

    redirect_back fallback_location: vendor_order_path(order), notice: notice
  end

  def order_params
    params.permit(:delivery_address, :notes, :discount_code, :payment_mode, order_items: [:product_id, :quantity])
  end
end
