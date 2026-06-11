class Vendor::BaseController < ApplicationController
  layout "vendor"
  before_action :authenticate_vendor!

  private

  # Vendor auth has two parts:
  #   1. There must be a logged-in user (custom session-based login sets
  #      session[:user_id]; see Vendor::SessionsController#login).
  #   2. That user must actually have the :vendor role. This blocks
  #      admins/customers/subadmins from poking at /vendor/* URLs.
  def authenticate_vendor!
    unless current_user
      redirect_to vendor_login_path, alert: "Please login as a vendor to access this area."
      return
    end

    unless current_user.vendor?
      redirect_to root_path, alert: "You are not authorized to access this area."
    end
  end
end
