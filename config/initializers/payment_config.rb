# Merchant UPI Configuration for Online Payments
# Each app can have its own UPI ID linked to that specific app

MERCHANT_UPI_IDS = {
  phonepe: "9472132493@ybl",
  gpay:    "srivastwasaurabh7@okicici",
  paytm:   "9472132493@ptyes"
}.freeze

MERCHANT_NAME       = ENV.fetch("MERCHANT_NAME", "Puroxa Water")
MERCHANT_UPI_QR_URL = ENV.fetch("MERCHANT_UPI_QR_URL", nil) # Optional: direct QR image URL
