class Customer::LandingController < ApplicationController
  def index
    @products = Product.active.limit(4)
  end
end
