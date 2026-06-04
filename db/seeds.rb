# ================== USERS ==================

# Admin
admin = User.find_or_initialize_by(email: "admin@puroxa.com")
admin.assign_attributes(
  first_name: "Admin",
  password: "password123",
  password_confirmation: "password123",
  role: :admin
)
admin.save!
puts "Created Admin: admin@puroxa.com / password123"

# Subadmin
subadmin = User.find_or_initialize_by(email: "subadmin@puroxa.com")
subadmin.assign_attributes(
  first_name: "Sub Admin",
  password: "password123",
  password_confirmation: "password123",
  role: :subadmin
)
subadmin.save!
puts "Created Subadmin: subadmin@puroxa.com / password123"

# Customer
customer = User.find_or_initialize_by(email: "customer@puroxa.com")
customer.assign_attributes(
  first_name: "Rahul",
  contact: "9876543210",
  password: "password123",
  password_confirmation: "password123",
  role: :customer
)
customer.save!
puts "Created Customer: customer@puroxa.com / password123"

# Customer Address
Address.find_or_create_by!(user: customer, label: "Home") do |addr|
  addr.address_line = "123 Main Street, Near City Center"
  addr.city = "Mumbai"
  addr.state = "Maharashtra"
  addr.pincode = "400001"
  addr.is_default = true
end

# Vendor User
vendor_user = User.find_or_initialize_by(email: "vendor@puroxa.com")
vendor_user.assign_attributes(
  first_name: "Sunil Paswan",
  contact: "9135080893",
  password: "123456",
  password_confirmation: "123456",
  role: :vendor
)
vendor_user.save!

# Vendor Profile
vendor = Vendor.find_or_initialize_by(user: vendor_user)
vendor.assign_attributes(
  shop_name: "Puroxa Water Supply",
  contact_number: "9135080893",
  address: "45 Market Road, Andheri West, Bihar",
  approved: true
)
vendor.save!
puts "Created Vendor: vendor@puroxa.com / 123456"

# ================== PRODUCTS ==================
products_data = [
  { name: "Puroxa 500ml", description: "Portable 500ml purified drinking water bottle, perfect for on-the-go.", size: "500ml", price: 10, stock_quantity: 500 },
  { name: "Puroxa 1 Litre", description: "1 Litre bottle for home and office use. RO purified and mineral enriched.", size: "1L", price: 20, stock_quantity: 400 },
  { name: "Puroxa 2 Litre", description: "2 Litre family pack. Best value for daily home consumption.", size: "2L", price: 40, stock_quantity: 300 },
  { name: "Puroxa 20 Litre Jar", description: "20 Litre jar for offices, shops and large families. Dispenser compatible.", size: "20L", price: 80, stock_quantity: 100 }
]

products_data.each do |data|
  Product.find_or_create_by!(name: data[:name]) do |p|
    p.assign_attributes(data.merge(active: true))
  end
end
puts "Created #{products_data.count} products"

# ================== SAMPLE ORDERS ==================
product_ids = Product.pluck(:id)

if product_ids.any? && customer.orders.count == 0
  3.times do |i|
    order = Order.create!(
      customer: customer,
      vendor: vendor_user,
      status: ["pending", "confirmed", "delivered"][i],
      payment_status: "pending",
      delivery_address: customer.addresses.first.full_address,
      notes: "Please deliver before 6 PM"
    )

    2.times do
      product = Product.order("RANDOM()").first
      qty = [1, 2, 5].sample
      OrderItem.create!(
        order: order,
        product: product,
        quantity: qty,
        unit_price: product.price
      )
    end

    order.calculate_total!
  end
  puts "Created 3 sample orders"
end

puts "✅ Seed complete!"
