require 'ostruct'

module Vendors
	class SignupService
		def initialize(params)
			@params = params
		end

		def call
			ActiveRecord::Base.transaction do
				user = create_user
				vendor = create_vendor(user)
				success(user, vendor)
			end
		rescue ActiveRecord::RecordInvalid => e
			failure([e.message])
		rescue StandardError => e
			failure(["Something went wrong: #{e.message}"])
		end

		private

		def create_user
			User.create!(
				email: @params[:email],
				password: @params[:password],
				contact: @params[:contact_number],
				role: :vendor
			)
		end

		def create_vendor(user)
			Vendor.create!(
				shop_name: @params[:shop_name],
				address: @params[:address],
				contact_number: @params[:contact_number],
				user: user
			)
		end

		def success(user, vendor)
			OpenStruct.new(success?: true, user: user, vendor: vendor)
		end

		def failure(errors)
			OpenStruct.new(success?: false, errors: errors)
		end
	end
end
