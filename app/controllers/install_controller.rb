class InstallController < ApplicationController
  def show
    # The full URL of the PWA that the QR code will encode.
    # On Render this is https://puroxa-water.onrender.com/
    @pwa_url = request.base_url
  end
end
