class Subadmin::CustomersController < Subadmin::BaseController
  def index
    @customers = User.where(role: User::ROLES[:customer]).order(created_at: :desc)
  end

  def show
    @customer = User.find(params[:id])
    @orders = @customer.orders.order(created_at: :desc).limit(10)
  end
end
