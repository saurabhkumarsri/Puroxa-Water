require 'ostruct'

module Orders
  class CreateService
    def initialize(customer, params)
      @customer = customer
      @params = params
    end

    def call
      ActiveRecord::Base.transaction do
        order = create_order
        create_order_items(order)
        order.calculate_total!
        apply_discount(order)
        success(order)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure([e.message])
    rescue StandardError => e
      failure(["Something went wrong: #{e.message}"])
    end

    private

    def create_order
      Order.create!(
        customer: @customer,
        status: "pending",
        payment_status: "pending",
        payment_mode: @params[:payment_mode].presence || "cash",
        delivery_address: @params[:delivery_address],
        notes: @params[:notes]
      )
    end

    def create_order_items(order)
      items = @params[:order_items] || []
      items.each do |item|
        next if item[:quantity].to_i <= 0

        product = Product.find(item[:product_id])
        if product.stock_quantity.to_i < item[:quantity].to_i
          raise ActiveRecord::RecordInvalid, "Not enough stock for #{product.name}"
        end

        OrderItem.create!(
          order: order,
          product: product,
          quantity: item[:quantity].to_i,
          unit_price: product.price
        )

        product.decrement!(:stock_quantity, item[:quantity].to_i)
      end
    end

    def apply_discount(order)
      code = @params[:discount_code].to_s.strip.presence
      return unless code

      discount = Discount.find_valid(code)
      return unless discount

      discount_amount = discount.apply(order.total_amount)
      return if discount_amount <= 0

      order.update!(
        discount: discount,
        discounted_amount: discount_amount,
        total_amount: order.total_amount - discount_amount
      )
      discount.increment!(:usage_count)
    end

    def success(order)
      OpenStruct.new(success?: true, order: order)
    end

    def failure(errors)
      OpenStruct.new(success?: false, errors: errors)
    end
  end
end
