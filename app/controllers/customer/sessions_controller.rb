class Customer::SessionsController < Devise::SessionsController
  # The redesigned customer login form sends flat params (user_email,
  # user_password) instead of the standard nested user[email] / user[password].
  # We can't just stuff those into params[:user] because Rails re-wraps
  # any hash assigned into ActionController::Parameters, and Devise's
  # warden strategy bails out (its `valid_params?` does
  # `params_auth_hash.is_a?(Hash)` which is false for Parameters objects).
  #
  # Instead, we authenticate manually with the looked-up user and then
  # call sign_in to start a session. We also accept email OR mobile
  # number (matching the placeholder text on the form) and enforce the
  # customer role so an admin/vendor can't sign in through this form.
  def create
    identifier = params[:user_email].to_s
    password   = params[:user_password].to_s

    user = User.where("email = :v OR contact = :v", v: identifier).first

    if user&.valid_password?(password) && user.customer?
      sign_in(:user, user)
      set_flash_message!(:notice, :signed_in) if is_flashing_format?
      respond_to do |format|
        format.any { redirect_to after_sign_in_path_for(user) }
      end
    else
      flash.now[:alert] = "Invalid Email/Mobile or password."
      self.resource = User.new(email: identifier)
      respond_to do |format|
        format.any { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message! :notice, :signed_out if signed_out
    redirect_to new_user_session_path, notice: "Logged out successfully", status: :see_other
  end
end
