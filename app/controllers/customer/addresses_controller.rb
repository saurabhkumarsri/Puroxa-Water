class Customer::AddressesController < Customer::BaseController
  def index
    @addresses = current_user.addresses
  end

  def new
    @address = current_user.addresses.new
  end

  def create
    @address = current_user.addresses.new(address_params)
    if @address.save
      redirect_to customer_addresses_path, notice: "Address added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @address = current_user.addresses.find(params[:id])
  end

  def update
    @address = current_user.addresses.find(params[:id])
    if @address.update(address_params)
      redirect_to customer_addresses_path, notice: "Address updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address = current_user.addresses.find(params[:id])
    @address.destroy
    redirect_to customer_addresses_path, notice: "Address deleted."
  end

  private

  def address_params
    params.require(:address).permit(:label, :address_line, :city, :state, :pincode, :is_default)
  end
end
