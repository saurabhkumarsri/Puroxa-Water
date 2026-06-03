class Customer::SessionsController < Devise::SessionsController
  def create
    self.resource = warden.authenticate!(auth_options)
    if resource.customer?
      set_flash_message!(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      sign_out(resource_name)
      flash[:alert] = "You are not authorized as customer"
      redirect_to new_user_session_path
    end
  end
end
