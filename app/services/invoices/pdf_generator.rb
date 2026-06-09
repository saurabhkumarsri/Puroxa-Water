require 'prawn'
require 'prawn/table'

module Invoices
  class PdfGenerator
    PAGE_WIDTH = 480

    def initialize(order)
      @order = order
    end

    def generate
      Prawn::Document.new(page_size: 'A4', margin: 40) do |pdf|
        # Company Header
        pdf.fill_color "0d2c63"
        pdf.font_size(22) { pdf.text "PUROXA WATER", style: :bold, align: :center }
        pdf.fill_color "555555"
        pdf.font_size(9) { pdf.text "Fresh Packaged Drinking Water", align: :center }
        pdf.font_size(8) { pdf.text "Phone: +91 98765 43210", align: :center }
        pdf.move_down 8
        pdf.stroke_color "0d2c63"
        pdf.line_width(1.5)
        pdf.stroke_horizontal_line 0, PAGE_WIDTH
        pdf.move_down 12

        # Challan Title
        pdf.fill_color "0d2c63"
        pdf.font_size(16) { pdf.text "DELIVERY CHALLAN / BILL", style: :bold, align: :center }
        pdf.move_down 10

        # Challan Info Box
        info_data = [
          ["Challan No:", "#{@order.id}", "Date:", "#{@order.created_at.strftime('%d/%m/%Y')}"],
          ["Time:", "#{@order.created_at.strftime('%I:%M %p')}", "Payment Mode:", "#{@order.payment_mode.to_s.upcase}"]
        ]
        pdf.table(info_data, width: PAGE_WIDTH, cell_style: { size: 9, padding: [3, 6], border_width: 0.5 }) do |t|
          t.columns(0).font_style = :bold
          t.columns(0).width = 80
          t.columns(1).width = 160
          t.columns(2).font_style = :bold
          t.columns(2).width = 80
          t.columns(3).width = 160
        end
        pdf.move_down 10

        # Customer Box
        pdf.fill_color "333333"
        pdf.font_size(10) { pdf.text "Customer Details", style: :bold }
        pdf.move_down 4
        cust_data = [
          ["Shop:", "#{pdf_text(@order.customer&.shop_name.to_s.presence || @order.customer&.display_name.to_s)}"],
          ["Area:", "#{pdf_text(@order.customer&.area.to_s.presence || '-')}"],
          ["Owner:", "#{pdf_text(@order.customer&.first_name.to_s.presence || '-')}"],
          ["Phone:", "#{pdf_text(@order.customer&.contact.to_s.presence || '-')}"],
          ["Address:", "#{pdf_text(@order.delivery_address.to_s.truncate(80).presence || '-')}"]
        ]
        pdf.table(cust_data, width: PAGE_WIDTH, cell_style: { size: 9, padding: [3, 6], border_width: 0.5 }) do |t|
          t.columns(0).font_style = :bold
          t.columns(0).width = 80
          t.columns(0).background_color = "f8f9fa"
        end
        pdf.move_down 12

        # Items Table
        pdf.font_size(10) { pdf.text "Items Delivered", style: :bold }
        pdf.move_down 4
        items_data = [["S.No", "Product", "Pack", "Qty", "Rate", "Amount"]]
        if @order.order_items.any?
          @order.order_items.each_with_index do |item, idx|
            product_name = pdf_text(item.product&.name.to_s)
            pack_size = item.product&.bottles_per_pack.to_s
            items_data << [
              "#{idx + 1}",
              product_name,
              "#{pack_size} bot/pack",
              "#{item.quantity}",
              "Rs.#{item.unit_price}",
              "Rs.#{item.total_price}"
            ]
          end
        else
          items_data << ["-", "-", "-", "-", "-", "-"]
        end

        pdf.table(items_data, width: PAGE_WIDTH, header: true, cell_style: { size: 9, padding: [4, 6], border_width: 0.5 }) do |t|
          t.row(0).background_color = "0d2c63"
          t.row(0).text_color = "ffffff"
          t.row(0).font_style = :bold
          t.columns(0).align = :center
          t.columns(0).width = 40
          t.columns(1).width = 150
          t.columns(2).width = 80
          t.columns(3).align = :center
          t.columns(3).width = 50
          t.columns(4).align = :right
          t.columns(4).width = 70
          t.columns(5).align = :right
          t.columns(5).width = 90
        end
        pdf.move_down 6

        # Totals Box
        previous_balance = calculate_previous_balance
        order_total = @order.total_amount.to_f
        received = @order.payment_status.to_s == "paid" ? order_total : 0.0
        current_balance = previous_balance + order_total - received

        totals_data = [
          ["", "", "", "Previous Balance:", "Rs.#{format('%.2f', previous_balance)}"],
          ["", "", "", "This Bill Amount:", "Rs.#{format('%.2f', order_total)}"],
          ["", "", "", "Total:", "Rs.#{format('%.2f', previous_balance + order_total)}"],
          ["", "", "", "Payment Received:", "Rs.#{format('%.2f', received)}"],
          ["", "", "", "Current Balance Due:", "Rs.#{format('%.2f', current_balance)}"]
        ]

        pdf.table(totals_data, width: PAGE_WIDTH, cell_style: { size: 10, padding: [4, 6], border_width: 0.5 }) do |t|
          t.columns(0).width = 40
          t.columns(0).borders = []
          t.columns(1).width = 150
          t.columns(1).borders = []
          t.columns(2).width = 80
          t.columns(2).borders = []
          t.columns(3).font_style = :bold
          t.columns(3).align = :right
          t.columns(3).width = 140
          t.columns(4).font_style = :bold
          t.columns(4).align = :right
          t.columns(4).width = 70
          t.row(-2).text_color = "059669"
          t.row(-1).text_color = current_balance > 0 ? "dc2626" : "059669"
          t.row(-1).background_color = "fef3c7"
        end
        pdf.move_down 12

        # Payment Status Box
        status_text = @order.payment_status.to_s == "paid" ? "PAID" : "PENDING - Please Pay"
        status_color = @order.payment_status.to_s == "paid" ? "059669" : "dc2626"
        pdf.fill_color status_color
        pdf.font_size(11) { pdf.text "Payment Status: #{status_text}", style: :bold }
        pdf.fill_color "333333"
        pdf.move_down 12

        # Signature Area
        pdf.stroke_color "999999"
        pdf.line_width(0.5)
        pdf.stroke_horizontal_line 0, 200
        pdf.move_down 4
        pdf.font_size(9) { pdf.text "Customer Signature", style: :bold }
        pdf.move_down 2
        pdf.font_size(8) { pdf.text "I have received the above items in good condition." }
        pdf.move_down 20

        # Notes
        if @order.notes.present?
          pdf.fill_color "666666"
          pdf.font_size(9) { pdf.text "Note: #{pdf_text(@order.notes)}" }
          pdf.move_down 10
        end

        # Footer
        pdf.stroke_color "cccccc"
        pdf.stroke_horizontal_line 0, PAGE_WIDTH
        pdf.move_down 6
        pdf.fill_color "666666"
        pdf.font_size(7) { pdf.text "Thank you for business! For any issue, contact: +91 98765 43210", align: :center }
        pdf.font_size(7) { pdf.text "This is a computer-generated challan and does not require a stamp.", align: :center }
      end
    end

    private

    def calculate_previous_balance
      return 0.0 unless @order.customer
      @order.customer.orders
        .where("created_at < ?", @order.created_at)
        .where.not(payment_status: "paid")
        .sum(:total_amount)
        .to_f
    end

    def pdf_text(str)
      return "" if str.nil?
      # Replace common non-ASCII chars with ASCII equivalents
      str = str.gsub("₹", "Rs.")
               .gsub("✓", "[OK]")
               .gsub("—", "-")
               .gsub("–", "-")
               .gsub("‘", "'")
               .gsub("’", "'")
               .gsub("“", "\"")
               .gsub("”", "\"")
      # Transliterate any remaining non-ASCII (e.g. Hindi) to ASCII approximations
      str = I18n.transliterate(str) rescue str
      str
    end
  end
end
