class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  helper_method :current_user

  def current_user
    @current_user ||= begin
      # Try Devise warden first (for admin, customer, subadmin)
      warden_user = defined?(warden) ? (warden.user rescue nil) : nil
      # Fall back to session-based auth (for vendor custom login)
      warden_user || User.find_by(id: session[:user_id])
    end
  end

  def authenticate_user!
    unless current_user
      redirect_to root_path, alert: "Please login first"
    end
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_dashboard_path
    elsif resource.subadmin?
      subadmin_dashboard_path
    elsif resource.customer?
      customer_dashboard_path
    else
      root_path
    end
  end
end
