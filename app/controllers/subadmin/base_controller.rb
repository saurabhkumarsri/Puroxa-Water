class Subadmin::BaseController < ApplicationController
  layout "admin"
  before_action :authenticate_user!
  before_action :ensure_subadmin!

  private

  def ensure_subadmin!
    unless current_user&.subadmin?
      redirect_to root_path, alert: "You are not authorized to access this area."
    end
  end
end
