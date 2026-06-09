class Admin::DiscountsController < Admin::BaseController
  def index
    @discounts = Discount.order(created_at: :desc)
  end

  def new
    @discount = Discount.new(active: true)
  end

  def create
    @discount = Discount.new(discount_params)
    if @discount.save
      redirect_to admin_discounts_path, notice: "Discount created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @discount = Discount.find(params[:id])
  end

  def update
    @discount = Discount.find(params[:id])
    if @discount.update(discount_params)
      redirect_to admin_discounts_path, notice: "Discount updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @discount = Discount.find(params[:id])
    @discount.destroy
    redirect_to admin_discounts_path, notice: "Discount deleted."
  end

  private

  def discount_params
    params.require(:discount).permit(
      :code, :discount_type, :value, :min_order_amount, :expiry_date, :usage_limit, :active
    )
  end
end
