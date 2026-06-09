require 'prawn'
require 'prawn/table'

module Invoices
  class PdfGenerator
    def initialize(order)
      @order = order
    end

    def generate
      Prawn::Document.new do |pdf|
        # Header
        pdf.fill_color "0d2c63"
        pdf.font_size(24) { pdf.text "PUROXA WATER", style: :bold }
        pdf.fill_color "333333"
        pdf.font_size(10) { pdf.text "Premium Drinking Water for Home, Office & Events" }
        pdf.move_down 5
        pdf.stroke_color "cccccc"
        pdf.stroke_horizontal_line 0, 500
        pdf.move_down 20

        # Invoice Title
        pdf.fill_color "0d2c63"
        pdf.font_size(18) { pdf.text "INVOICE", style: :bold }
        pdf.fill_color "333333"
        pdf.font_size(10) { pdf.text "Invoice #: INV-#{@order.id}-#{@order.created_at.strftime('%Y%m%d')}" }
        pdf.font_size(10) { pdf.text "Date: #{@order.created_at.strftime('%d %b %Y, %I:%M %p')}" }
        pdf.move_down 15

        # Order Details
        pdf.font_size(11) { pdf.text "Order Details", style: :bold }
        pdf.move_down 5
        data = [
          ["Order ID", "##{@order.id}"],
          ["Status", @order.status.to_s.titleize],
          ["Payment Status", @order.payment_status.to_s.titleize],
          ["Payment Mode", @order.payment_mode.to_s.upcase],
          ["Customer", @order.customer&.display_name.to_s],
          ["Vendor", @order.vendor&.display_name.to_s.presence || "—"],
          ["Delivery Address", @order.delivery_address.to_s.truncate(60)]
        ]
        pdf.table(data, width: 500, cell_style: { size: 9, padding: [4, 8] }) do |t|
          t.columns(0).background_color = "f3f4f6"
          t.columns(0).font_style = :bold
          t.columns(0).width = 150
        end
        pdf.move_down 20

        # Items Table
        pdf.font_size(11) { pdf.text "Items", style: :bold }
        pdf.move_down 5
        items_data = [["Product", "Pack Size", "Qty", "Unit Price", "Total"]]

        if @order.order_items.any?
          @order.order_items.each do |item|
            product_name = item.product&.name.to_s
            pack_size = item.product&.bottles_per_pack.to_s
            items_data << [
              product_name,
              "#{pack_size} bottles/pack",
              "#{item.quantity} packs",
              "₹#{item.unit_price}",
              "₹#{item.total_price}"
            ]
          end
        else
          items_data << ["—", "—", "—", "—", "—"]
        end

        # Add discount row if applicable
        if @order.discount.present?
          items_data << ["", "", "", "Subtotal:", "₹#{@order.order_items.sum(:total_price)}"]
          items_data << ["", "", "", "Discount (#{@order.discount.code}):", "-₹#{@order.discounted_amount}"]
        end
        items_data << ["", "", "", "Grand Total:", "₹#{@order.total_amount}"]

        pdf.table(items_data, width: 500, header: true, cell_style: { size: 9, padding: [5, 8] }) do |t|
          t.row(0).background_color = "0d2c63"
          t.row(0).text_color = "ffffff"
          t.row(0).font_style = :bold
          t.columns(3).align = :right
          t.columns(4).align = :right
          if @order.discount.present?
            t.row(-3).font_style = :bold
            t.row(-2).text_color = "059669"
            t.row(-1).background_color = "f3f4f6"
            t.row(-1).font_style = :bold
          else
            t.row(-1).background_color = "f3f4f6"
            t.row(-1).font_style = :bold
          end
        end
        pdf.move_down 20

        # Notes
        if @order.notes.present?
          pdf.font_size(11) { pdf.text "Notes", style: :bold }
          pdf.move_down 5
          pdf.font_size(9) { pdf.text @order.notes.to_s }
          pdf.move_down 20
        end

        # Footer
        pdf.stroke_color "cccccc"
        pdf.stroke_horizontal_line 0, 500
        pdf.move_down 10
        pdf.fill_color "666666"
        pdf.font_size(8) { pdf.text "Thank you for choosing Puroxa Water! For support, contact: support@puroxa.com | +91 98765 43210" }
      end
    end
  end
end
