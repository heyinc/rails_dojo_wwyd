require "test_helper"

class Dashboard::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(User.take) }

  test "should get index" do
    get dashboard_orders_path
    assert_response :success
  end

  test "should get new" do
    reservation = Reservation.take || Reservation.create!(name: "Test", email: "test@example.com")
    get new_dashboard_order_path(reservation_id: reservation.id)
    assert_response :success
  end
end
