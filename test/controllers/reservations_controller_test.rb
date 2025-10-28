require "test_helper"

class ReservationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get reservations_new_url
    assert_response :success
  end

  test "should get create" do
    get reservations_create_url
    assert_response :success
  end
end
