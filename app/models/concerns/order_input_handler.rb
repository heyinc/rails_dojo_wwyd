# frozen_string_literal: true

module OrderInputHandler
  def build_order_and_payment
    order = reservation.build_order
    order.assign_attributes(params.expect(order: %i[email name item_id user_id]))
    payment = order.build_payment
    payment.assign_attributes(amount: order.item.price)

    [ order, payment ]
  end

  private

  def reservation = Reservation.find(params.dig(:order, :reservation_id))

  def reservation_id = params.dig(:order, :reservation_id)
end