class Order < ApplicationRecord
  belongs_to :reservation
  belongs_to :user
  belongs_to :item
  has_one :payment, dependent: :destroy

  validates :email, presence: true
  validates :name, presence: true

  def execute_payment_and_update_reservation_and_item(token:)
    response = PaymentApiClient.execute(token:, amount: item.price)

    ActiveRecord::Base.transaction do
      build_payment(payment_id: response[:payment_id], amount: response[:amount])
      if reservation.status == "completed"
        raise ActiveRecord::RecordInvalid, "Reservation is already completed"
      end
      reservation.update!(status: :completed)
      item.update!(stock: item.stock - 1)
      save!
    end

    true
  rescue Timeout::Error, ArgumentError
    false
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
    false
  end
end
