class Customer::InvoicesController < Customer::BaseController
  def show
    @order = current_user.orders.find(params[:id])
    pdf = Invoices::PdfGenerator.new(@order).generate
    send_data pdf.render,
      filename: "invoice_#{@order.id}_#{@order.created_at.strftime('%Y%m%d')}.pdf",
      type: "application/pdf",
      disposition: "inline"
  end
end
