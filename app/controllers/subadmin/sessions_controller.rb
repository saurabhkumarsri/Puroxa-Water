class Subadmin::SessionsController < Devise::SessionsController
  def create
    self.resource = warden.authenticate!(auth_options)
    if resource.subadmin?
      set_flash_message!(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      sign_out(resource_name)
      flash[:alert] = "You are not authorized as subadmin"
      redirect_to subadmin_login_path
    end
  end
end
