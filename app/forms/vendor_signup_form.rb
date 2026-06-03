class VendorSignupForm
	include ActiveModel::Model

	attr_accessor :email, :password, :shop_name ,:contact_number, :address

	validates :email, :password, :shop_name, :address, presence: true

	validates :password, length: {minimum: 6}
end