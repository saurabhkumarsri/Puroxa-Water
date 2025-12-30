require "test_helper"

class Customer::LandingControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get customer_landing_index_url
    assert_response :success
  end
end
