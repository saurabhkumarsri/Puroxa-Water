class Vendor::SessionsController < ApplicationController
  def new
  end

  def login
    identifier = params[:login]
    password   = params[:password]

    user = User.find_by(
      "email = :value OR contact = :value",
      value: identifier
    )

    Rails.logger.debug "USER => #{user.inspect}==========================================="

    if user&.valid_password?(password)
      session[:user_id] = user.id
      redirect_to vendor_dashboards_index_path, notice: "Login successful"
    else
      flash.now[:alert] = "Invalid email/mobile or password"
      render :new, status: :unprocessable_entity
    end
  end


  def destroy
    session[:user_id] = nil
    redirect_to vendor_login_path
  end
end
