class Admin::CustomersController < Admin::BaseController
  def index
    @customers = User.where(role: User::ROLES[:customer]).order(created_at: :desc)
  end

  def show
    @customer = User.find(params[:id])
    @orders = @customer.orders.order(created_at: :desc).limit(10)
  end

  def edit
    @customer = User.find(params[:id])
  end

  def update
    @customer = User.find(params[:id])
    if @customer.update(customer_params)
      redirect_to admin_customers_path, notice: "Customer updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @customer = User.find(params[:id])
    @customer.destroy
    redirect_to admin_customers_path, notice: "Customer deleted."
  end

  private

  def customer_params
    params.require(:user).permit(:first_name, :email, :contact, :shop_name, :area, :gst_number, :credit_limit)
  end
end
