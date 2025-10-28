require "test_helper"

class Dashboard::ReservationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dashboard_reservations_index_url
    assert_response :success
  end
end
