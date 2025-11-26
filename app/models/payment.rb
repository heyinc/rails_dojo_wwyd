class Payment < ApplicationRecord
  belongs_to :order

  validates :payment_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }

  class << self
    def process_payment!(order:, item:, token:)
      result = PaymentApiClient.execute(token:, amount: item.price)
      Payment.create!(order:, payment_id: result[:payment_id], amount: result[:amount])
    end
  end
end
