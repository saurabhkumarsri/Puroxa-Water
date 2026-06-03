class Admin::SubadminsController < Admin::BaseController
  def index
    @subadmins = User.where(role: User::ROLES[:subadmin]).order(created_at: :desc)
  end

  def new
    @subadmin = User.new
  end

  def create
    @subadmin = User.new(subadmin_params)
    @subadmin.role = :subadmin
    if @subadmin.save
      redirect_to admin_subadmins_path, notice: "Subadmin created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @subadmin = User.find(params[:id])
  end

  def update
    @subadmin = User.find(params[:id])
    if @subadmin.update(subadmin_params)
      redirect_to admin_subadmins_path, notice: "Subadmin updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @subadmin = User.find(params[:id])
    @subadmin.destroy
    redirect_to admin_subadmins_path, notice: "Subadmin deleted."
  end

  private

  def subadmin_params
    params.require(:user).permit(:first_name, :email, :password, :password_confirmation, :contact)
  end
end
