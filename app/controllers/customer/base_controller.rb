class Customer::BaseController < ApplicationController
  layout "customer"
  before_action :authenticate_user!
  before_action :ensure_customer!

  private

  def ensure_customer!
    unless current_user&.customer?
      redirect_to root_path, alert: "Please login as a customer to access this area."
    end
  end
end
