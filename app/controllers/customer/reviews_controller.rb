class Customer::ReviewsController < Customer::BaseController
  def create
    @order = current_user.orders.find(params[:order_id])

    if @order.review.present?
      redirect_to customer_order_path(@order), alert: "You have already reviewed this order."
      return
    end

    unless @order.delivered?
      redirect_to customer_order_path(@order), alert: "You can only review delivered orders."
      return
    end

    @review = @order.build_review(
      customer: current_user,
      vendor: @order.vendor,
      rating: params[:rating],
      comment: params[:comment]
    )

    if @review.save
      redirect_to customer_order_path(@order), notice: "Thank you for your feedback!"
    else
      redirect_to customer_order_path(@order), alert: "Something went wrong. Please try again."
    end
  end
end
