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

  private

  def order_params
    params.permit(:delivery_address, :notes, :discount_code, :payment_mode, order_items: [:product_id, :quantity])
  end
end
