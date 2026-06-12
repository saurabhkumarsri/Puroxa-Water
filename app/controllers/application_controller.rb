class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  helper_method :current_user

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :contact])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :contact])
  end

  public

  def current_user
    @current_user ||= begin
      # Try Devise warden first (for admin and customer — vendor uses custom
      # session-based auth set in Vendor::SessionsController#login)
      warden_user = defined?(warden) ? (warden.user rescue nil) : nil
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
    elsif resource.customer?
      customer_dashboard_path
    else
      root_path
    end
  end
end
