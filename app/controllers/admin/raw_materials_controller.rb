class Admin::RawMaterialsController < Admin::BaseController
  def index
    @raw_materials = RawMaterial.order(:category, :name)
    @low_stock_count = RawMaterial.where("quantity <= min_stock_level").count
  end

  def new
    @raw_material = RawMaterial.new
  end

  def create
    @raw_material = RawMaterial.new(raw_material_params)
    if @raw_material.save
      redirect_to admin_raw_materials_path, notice: "Raw material added successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @raw_material = RawMaterial.find(params[:id])
  end

  def update
    @raw_material = RawMaterial.find(params[:id])
    if @raw_material.update(raw_material_params)
      redirect_to admin_raw_materials_path, notice: "Raw material updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @raw_material = RawMaterial.find(params[:id])
    @raw_material.destroy
    redirect_to admin_raw_materials_path, notice: "Raw material deleted."
  end

  private

  def raw_material_params
    params.require(:raw_material).permit(
      :name, :category, :quantity, :unit, :min_stock_level, :cost_per_unit, :supplier_name
    )
  end
end
