class Customer::ProductsController < Customer::BaseController
  def index
    @products = Product.active.order(:name)
  end
end
