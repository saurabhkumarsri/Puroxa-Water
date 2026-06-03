class Vendor < ApplicationRecord
  belongs_to :user

  validates :shop_name, :address, presence: true

  delegate :email, :contact, :display_name, to: :user

  def approved!
    update!(approved: true)
  end

  def rejected!
    update!(approved: false)
  end
end
