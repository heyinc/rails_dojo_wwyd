require "test_helper"

class Dashboard::OrdersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dashboard_orders_index_url
    assert_response :success
  end

  test "should get new" do
    get dashboard_orders_new_url
    assert_response :success
  end
end
