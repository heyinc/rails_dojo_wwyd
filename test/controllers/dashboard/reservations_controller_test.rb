require "test_helper"

class Dashboard::ReservationsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "should get index" do
    get dashboard_reservations_path
    assert_response :success
  end
end
