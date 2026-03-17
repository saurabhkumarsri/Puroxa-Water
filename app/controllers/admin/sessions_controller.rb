class Admin::SessionsController < Devise::SessionsController

  def create
    super do |user|
      unless user.admin?
        sign_out user
        P "============================================================================oooo"
        redirect_to new_user_session_path,
          alert: "You are not authorized as admin"
        return
      end
    end
  end

end
