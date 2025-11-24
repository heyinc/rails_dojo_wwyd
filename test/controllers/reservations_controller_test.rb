require "test_helper"

class ReservationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_reservation_path
    assert_response :success
  end

  test "should get create" do
    post reservations_path, params: { reservation: { name: "Test", email: "test@example.com" } }
    assert_response :redirect
  end
end
