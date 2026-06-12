# frozen_string_literal: true

# ================== USERS ==================

# Admin
admin = User.find_or_initialize_by(email: "admin@puroxa.com")
admin.assign_attributes(
  first_name: "Admin",
  password: "123456",
  contact: "9472132493",
  password_confirmation: "123456",
  role: :admin
)
admin.save!
puts "Created Admin: admin@puroxa.com / 123456"

# ================== CUSTOMERS (Shop Owners) ==================
customers_data = [
  {
    email: "customer@puroxa.com",
    first_name: "Rahul",
    shop_name: "Gupta Kirana Store",
    area: "Main Market",
    contact: "9876543210",
    credit_limit: 5000.00
  },
  {
    email: "saurabh@gmail.com",
    first_name: "Saurabh",
    shop_name: "Sharma General Store",
    area: "Gandhi Road",
    contact: "9876543211",
    gst_number: "22ABCDE1234F1Z5",
    credit_limit: 10000.00
  },
  {
    email: "ramesh.shop@gmail.com",
    first_name: "Ramesh",
    shop_name: "Ramesh Cool Point",
    area: "Bus Stand Road",
    contact: "9876543212",
    credit_limit: 3000.00
  },
  {
    email: "priya.dukan@gmail.com",
    first_name: "Priya",
    shop_name: "Priya Departmental Store",
    area: "Station Road",
    contact: "9876543213",
    gst_number: "22FGHIJ5678K2Z6",
    credit_limit: 8000.00
  },
  {
    email: "vikram.store@gmail.com",
    first_name: "Vikram",
    shop_name: "Vikram Provision Store",
    area: "M.G. Road",
    contact: "9876543214",
    credit_limit: 12000.00
  },
  {
    email: "anjali.shop@gmail.com",
    first_name: "Anjali",
    shop_name: "Anjali Footwear & General",
    area: "Main Market",
    contact: "9876543215",
    credit_limit: 6000.00
  }
]

created_customers = []
customers_data.each do |data|
  user = User.find_or_initialize_by(email: data[:email])
  user.assign_attributes(
    first_name: data[:first_name],
    shop_name: data[:shop_name],
    area: data[:area],
    contact: data[:contact],
    gst_number: data[:gst_number],
    credit_limit: data[:credit_limit],
    password: "123456",
    password_confirmation: "123456",
    role: :customer
  )
  user.save!
  created_customers << user
  puts "Created Customer: #{data[:email]} | Shop: #{data[:shop_name]} | Area: #{data[:area]}"
end

# ================== ADDRESSES ==================
addresses_data = [
  { user_email: "customer@puroxa.com", label: "Shop", address_line: "123 Main Street, Near City Center", city: "Patna", state: "Bihar", pincode: "800001", is_default: true },
  { user_email: "customer@puroxa.com", label: "Godown", address_line: "45 Warehouse Lane, Industrial Area", city: "Patna", state: "Bihar", pincode: "800002", is_default: false },
  { user_email: "saurabh@gmail.com", label: "Shop", address_line: "78 Gandhi Road, Opposite Bank", city: "Patna", state: "Bihar", pincode: "800003", is_default: true },
  { user_email: "ramesh.shop@gmail.com", label: "Shop", address_line: "22 Bus Stand Road, Near Petrol Pump", city: "Patna", state: "Bihar", pincode: "800004", is_default: true },
  { user_email: "priya.dukan@gmail.com", label: "Shop", address_line: "56 Station Road, Platform No. 3 Side", city: "Patna", state: "Bihar", pincode: "800005", is_default: true },
  { user_email: "vikram.store@gmail.com", label: "Shop", address_line: "90 M.G. Road, Gandhi Maidan", city: "Patna", state: "Bihar", pincode: "800006", is_default: true },
  { user_email: "anjali.shop@gmail.com", label: "Shop", address_line: "34 Main Market, Opposite Post Office", city: "Patna", state: "Bihar", pincode: "800007", is_default: true }
]

addresses_data.each do |data|
  user = User.find_by(email: data[:user_email])
  next unless user
  Address.find_or_create_by!(user: user, label: data[:label]) do |addr|
    addr.address_line = data[:address_line]
    addr.city = data[:city]
    addr.state = data[:state]
    addr.pincode = data[:pincode]
    addr.is_default = data[:is_default]
  end
end
puts "Created #{addresses_data.count} addresses"

# ================== VENDORS ==================
vendors_data = [
  {
    email: "vendor@puroxa.com",
    first_name: "Sunil",
    shop_name: "Puroxa Water Supply",
    contact: "9135080893",
    address: "45 Market Road, Andheri West"
  },
  {
    email: "vendor2@puroxa.com",
    first_name: "Mohan",
    shop_name: "Mohan Water Delivery",
    contact: "9135080894",
    address: "78 Gandhi Road, Patna"
  },
  {
    email: "vendor3@puroxa.com",
    first_name: "Deepak",
    shop_name: "Deepak Aqua Services",
    contact: "9135080895",
    address: "22 Bus Stand Road, Patna"
  }
]

vendor_users = []
vendors_data.each do |data|
  user = User.find_or_initialize_by(email: data[:email])
  user.assign_attributes(
    first_name: data[:first_name],
    contact: data[:contact],
    password: "123456",
    password_confirmation: "123456",
    role: :vendor
  )
  user.save!

  vendor = Vendor.find_or_initialize_by(user: user)
  vendor.assign_attributes(
    shop_name: data[:shop_name],
    contact_number: data[:contact],
    address: data[:address],
    approved: true
  )
  vendor.save!
  vendor_users << user
  puts "Created Vendor: #{data[:email]} | #{data[:shop_name]}"
end

# ================== WORKERS ==================
workers_data = [
  { name: "Ram Prasad", phone: "9876500001", email: "ram@puroxa.com", salary: 12000, identity_type: "Aadhaar", identity_number: "1234 5678 9012", address: "Village Road, Patna", status: "Active", joining_date: Date.parse("2024-01-15") },
  { name: "Shyam Lal", phone: "9876500002", email: "shyam@puroxa.com", salary: 11000, identity_type: "Voter_ID", identity_number: "ABC1234567", address: "Main Market, Patna", status: "Active", joining_date: Date.parse("2024-03-10") },
  { name: "Bablu Kumar", phone: "9876500003", email: "bablu@puroxa.com", salary: 13000, identity_type: "PAN", identity_number: "ABCDE1234F", address: "Gandhi Road, Patna", status: "Active", joining_date: Date.parse("2024-02-01") },
  { name: "Pappu Singh", phone: "9876500004", email: "pappu@puroxa.com", salary: 10000, identity_type: "Aadhaar", identity_number: "9876 5432 1098", address: "Station Road, Patna", status: "Inactive", joining_date: Date.parse("2024-04-20") }
]

workers_data.each do |data|
  Worker.find_or_create_by!(email: data[:email]) do |w|
    w.assign_attributes(data)
  end
end
puts "Created #{workers_data.count} workers"

# ================== RAW MATERIALS ==================
materials_data = [
  { name: "PET Plastic Preforms", quantity: 5000, unit: "pieces", cost_per_unit: 2.5, category: "Packaging", min_stock_level: 500 },
  { name: "Bottle Caps (28mm)", quantity: 10000, unit: "pieces", cost_per_unit: 0.5, category: "Cap", min_stock_level: 1000 },
  { name: "Labels (500ml)", quantity: 8000, unit: "pieces", cost_per_unit: 0.8, category: "Label", min_stock_level: 800 },
  { name: "Shrink Wrap Film", quantity: 200, unit: "kg", cost_per_unit: 150.0, category: "Packaging", min_stock_level: 50 },
  { name: "RO Membrane Filters", quantity: 10, unit: "pieces", cost_per_unit: 3500.0, category: "Other", min_stock_level: 2 },
  { name: "Chlorine Tablets", quantity: 50, unit: "bottles", cost_per_unit: 120.0, category: "Chemical", min_stock_level: 10 },
  { name: "Cardboard Boxes", quantity: 500, unit: "pieces", cost_per_unit: 15.0, category: "Packaging", min_stock_level: 50 }
]

materials_data.each do |data|
  RawMaterial.find_or_create_by!(name: data[:name]) do |rm|
    rm.assign_attributes(data)
  end
end
puts "Created #{materials_data.count} raw materials"

# ================== PRODUCTS ==================
products_data = [
  { name: "Puroxa 500ml", description: "Portable 500ml purified drinking water bottle, perfect for on-the-go.", size: "500ml", price: 10, bottles_per_pack: 24, stock_quantity: 500, active: true },
  { name: "Puroxa 1 Litre", description: "1 Litre bottle for home and office use. RO purified and mineral enriched.", size: "1L", price: 20, bottles_per_pack: 12, stock_quantity: 400, active: true },
  { name: "Puroxa 2 Litre", description: "2 Litre family pack. Best value for daily home consumption.", size: "2L", price: 40, bottles_per_pack: 6, stock_quantity: 300, active: true },
  { name: "Puroxa 20 Litre Jar", description: "20 Litre jar for offices, shops and large families. Dispenser compatible.", size: "20L", price: 80, bottles_per_pack: 1, stock_quantity: 100, active: true },
  { name: "Puroxa 250ml Cup", description: "Small 250ml cup for events and parties. Easy to carry.", size: "250ml", price: 5, bottles_per_pack: 48, stock_quantity: 800, active: true },
  { name: "Puroxa 5 Litre Can", description: "5 Litre can for picnics and small gatherings.", size: "5L", price: 50, bottles_per_pack: 2, stock_quantity: 200, active: true }
]

products_data.each do |data|
  Product.find_or_create_by!(name: data[:name]) do |p|
    p.assign_attributes(data)
  end
end
puts "Created #{products_data.count} products"

# ================== DISCOUNTS ==================
discounts_data = [
  { code: "PUROXA10", discount_type: "percentage", value: 10, min_order_amount: 500, active: true, expiry_date: Date.current + 30.days, usage_limit: 100, usage_count: 0 },
  { code: "NEW50", discount_type: "fixed", value: 50, min_order_amount: 300, active: true, expiry_date: Date.current + 15.days, usage_limit: 50, usage_count: 0 },
  { code: "BULK20", discount_type: "percentage", value: 20, min_order_amount: 2000, active: true, expiry_date: Date.current + 60.days, usage_limit: 200, usage_count: 0 }
]

discounts_data.each do |data|
  Discount.find_or_create_by!(code: data[:code]) do |d|
    d.assign_attributes(data)
  end
end
puts "Created #{discounts_data.count} discounts"

# ================== SAMPLE ORDERS ==================
if created_customers.any? && vendor_users.any? && Product.count > 0
  # Delete old sample orders if any
  Order.where("notes = ? OR notes = ?", "Please deliver before 6 PM", nil).where("created_at < ?", 1.day.ago).destroy_all rescue nil

  statuses = %w[pending confirmed processing shipped delivered cancelled]
  payment_statuses = %w[pending paid]
  payment_modes = %w[cash online]
  notes = [
    "Please deliver before 6 PM",
    "Deliver at back entrance",
    "Call before coming",
    "Bring exact change",
    "Customer will pay cash",
    "UPI payment done",
    nil,
    nil
  ]

  order_count = 0
  created_customers.each_with_index do |customer, c_idx|
    vendor = vendor_users.sample
    address = customer.addresses.first&.full_address || "Patna, Bihar"

    # Create 3-5 orders per customer
    rand(3..5).times do |i|
      status = statuses.sample
      p_status = payment_statuses.sample
      p_mode = payment_modes.sample

      order = Order.create!(
        customer: customer,
        vendor: vendor,
        status: status,
        payment_status: p_status,
        payment_mode: p_mode,
        delivery_address: address,
        notes: notes.sample
      )

      # Add 1-3 items per order
      rand(1..3).times do
        product = Product.order("RANDOM()").first
        qty = [1, 2, 5, 10, 20].sample
        OrderItem.create!(
          order: order,
          product: product,
          quantity: qty,
          unit_price: product.price
        )
      end

      order.calculate_total!

      # If payment is paid, set paid_at randomly within last 7 days
      if p_status == "paid"
        order.update!(paid_at: rand(1..7).days.ago + rand(9..17).hours)
      end

      order_count += 1
    end
  end

  puts "Created #{order_count} sample orders"

  # Create a few recent paid orders specifically for today's collection demo
  3.times do
    customer = created_customers.sample
    vendor = vendor_users.sample
    p_mode = payment_modes.sample

    order = Order.create!(
      customer: customer,
      vendor: vendor,
      status: "delivered",
      payment_status: "paid",
      payment_mode: p_mode,
      paid_at: Time.current - rand(1..6).hours,
      delivery_address: customer.addresses.first&.full_address || "Patna, Bihar",
      notes: "Paid via #{p_mode}"
    )

    product = Product.order("RANDOM()").first
    qty = [5, 10, 20].sample
    OrderItem.create!(
      order: order,
      product: product,
      quantity: qty,
      unit_price: product.price
    )

    order.calculate_total!
  end
  puts "Created 3 today's paid orders for collection demo"
end

puts ""
puts "=========================================="
puts "SEED COMPLETE! Login credentials:"
puts "=========================================="
puts "Admin:     admin@puroxa.com     / 123456"
puts "Vendor 1:  vendor@puroxa.com   / 123456  (or 9135080893)"
puts "Vendor 2:  vendor2@puroxa.com  / 123456  (or 9135080894)"
puts "Vendor 3:  vendor3@puroxa.com  / 123456  (or 9135080895)"
puts "Customer:  customer@puroxa.com / 123456  (or 9876543210)"
puts "Customer:  saurabh@gmail.com   / 123456  (or 9876543211)"
puts "Customer:  ramesh.shop@gmail.com / 123456 (or 9876543212)"
puts "Customer:  priya.dukan@gmail.com / 123456 (or 9876543213)"
puts "Customer:  vikram.store@gmail.com / 123456 (or 9876543214)"
puts "Customer:  anjali.shop@gmail.com / 123456 (or 9876543215)"
puts "=========================================="
puts "NOTE: Customer & Vendor can login with Email OR Mobile Number"
puts "=========================================="
puts ""
