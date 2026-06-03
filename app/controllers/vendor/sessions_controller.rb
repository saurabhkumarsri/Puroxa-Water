class Vendor::SessionsController < ApplicationController
  def new
  end

  def sign_up
    @form = VendorSignupForm.new
  end

  def login
    identifier = params[:login]
    password   = params[:password]

    user = User.find_by(
      "email = :value OR contact = :value",
      value: identifier
    )
    if user&.valid_password?(password) && user.vendor?
      session[:user_id] = user.id
      redirect_to vendor_dashboard_path, notice: "Login successful"
    else
      flash.now[:alert] = "Invalid email/mobile or password"
      render :new, status: :unprocessable_entity
    end
  end

  def create
    @form = VendorSignupForm.new(form_params)
    if @form.valid?
      result = Vendors::SignupService.new(form_params).call
      if result.success?
        redirect_to root_path, notice: "Vendor Signup Successful"
      else
        flash.now[:alert] = result.errors.join(", ")
        render :new
      end
    else
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Logged out successfully"
  end

  private

  def form_params
    params.require(:vendor_signup_form).permit(:email, :password, :shop_name, :contact_number, :address)
  end
end
