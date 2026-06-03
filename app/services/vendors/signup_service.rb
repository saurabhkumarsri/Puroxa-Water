require 'ostruct' 

module Vendors
	class SignupService
		def initialize(params)
			@params = params
		end

		def call
			user = create_user
			vendor = create_vendor(user)
			success(user, vendor)
		end

		private

		def create_user
			User.create!(
				email: @params[:email],
				password: @params[:password],
				contact: @params[:contact],
				role: :vendor
			)
		end

		def create_vendor(user)
			Vendor.create!(
				shop_name: @params[:shop_name],
				address: @params[:address],
				user: user
			)
		end

		def success(user, vendor)
			OpenStruct.new(success?: true, user: user, vendor: vendor)
		end
	end
end