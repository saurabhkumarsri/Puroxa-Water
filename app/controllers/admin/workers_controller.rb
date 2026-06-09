class Admin::WorkersController < Admin::BaseController
  def index
    @workers = Worker.order(created_at: :desc)
  end

  def show
    @worker = Worker.find(params[:id])
  end

  def new
    @worker = Worker.new(status: "Active")
  end

  def create
    @worker = Worker.new(worker_params)
    if @worker.save
      redirect_to admin_workers_path, notice: "Worker created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @worker = Worker.find(params[:id])
  end

  def update
    @worker = Worker.find(params[:id])
    if @worker.update(worker_params)
      redirect_to admin_workers_path, notice: "Worker updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @worker = Worker.find(params[:id])
    @worker.destroy
    redirect_to admin_workers_path, notice: "Worker deleted."
  end

  private

  def worker_params
    params.require(:worker).permit(
      :name, :phone, :email, :address, :identity_type, :identity_number,
      :joining_date, :salary, :status, :emergency_contact, :notes, :document, :profile_picture
    )
  end
end
