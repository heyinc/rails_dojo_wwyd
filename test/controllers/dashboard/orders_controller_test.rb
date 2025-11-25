require "test_helper"

class Dashboard::OrdersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "should get index" do
    get dashboard_orders_path
    assert_response :success
  end

  test "should get new" do
    reservation = reservations(:one)
    get new_dashboard_order_path(reservation_id: reservation.id)
    assert_response :success
  end

  test "should get create" do
    reservation = reservations(:one)
    item = items(:one)
    user = users(:one)
    initial_stock = item.stock
    token = SecureRandom.alphanumeric(32)

    post dashboard_orders_path, params: {
      order: {
        reservation_id: reservation.id,
        item_id: item.id,
        user_id: user.id,
        token: token
      }
    }

    assert_redirected_to dashboard_orders_path
    assert_equal "注文が作成されました", flash[:notice]

    assert_equal 1, Order.count

    order = Order.first
    assert_equal reservation.id, order.reservation_id
    assert_equal item.id, order.item_id
    assert_equal user.id, order.user_id
    assert_equal reservation.email, order.email
    assert_equal item.name, order.name

    payment = order.payment
    assert_not_nil payment
    assert_equal item.price, payment.amount
    assert_match(/^PAY_\d{8}_[A-Z0-9]{9}$/, payment.payment_id)

    reservation.reload
    assert_equal "completed", reservation.status

    item.reload
    assert_equal initial_stock - 1, item.stock
  end
end
