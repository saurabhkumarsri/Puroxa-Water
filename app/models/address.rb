class Address < ApplicationRecord
  belongs_to :user

  validates :address_line, :city, :state, :pincode, presence: true

  after_save :ensure_single_default, if: :is_default?

  def full_address
    "#{address_line}, #{city}, #{state} - #{pincode}"
  end

  private

  def ensure_single_default
    user.addresses.where.not(id: id).update_all(is_default: false)
  end
end
