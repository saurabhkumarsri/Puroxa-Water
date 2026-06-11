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
      result.order.update!(vendor: current_user)
      redirect_to vendor_orders_path, notice: "Order created successfully for #{customer.display_name}!"
    else
      flash.now[:alert] = result.errors.join(", ")
      @products = Product.active.order(:name)
      @customers = User.where(role: User::ROLES[:customer]).order(:first_name)
      render :new, status: :unprocessable_entity
    end
  end

  def update_status
    @order = Order.find(params[:id])
    allowed = %w[confirmed processing shipped delivered]
    if allowed.include?(params[:status])
      @order.update!(status: params[:status])

      # Send notification to customer
      Notification.create!(
        customer: @order.customer,
        order: @order,
        title: "Order ##{@order.id} #{params[:status].titleize}",
        body: "Your order has been #{params[:status]} by #{current_user.display_name}."
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
      if @order.payment_mode == "online"
        @order.remove_online_discount!
      end

      @order.update!(payment_status: "paid", paid_at: Time.current)
      redirect_back fallback_location: vendor_order_path(@order), notice: "Payment collected successfully! Cash collected — online discount removed."
    else
      redirect_back fallback_location: vendor_order_path(@order), alert: "Payment is already #{@order.payment_status}."
    end
  end

  def confirm_online
    @order = Order.find(params[:id])
    if @order.payment_pending? && @order.payment_mode == "online"
      @order.apply_online_discount!
      @order.update!(payment_status: "paid", paid_at: Time.current)
      redirect_back fallback_location: vendor_order_path(@order), notice: "Online payment confirmed. Discount applied."
    else
      redirect_back fallback_location: vendor_order_path(@order), alert: "Cannot confirm online payment for this order."
    end
  end

  private

  def order_params
    params.permit(:delivery_address, :notes, :discount_code, :payment_mode, order_items: [:product_id, :quantity])
  end
end
