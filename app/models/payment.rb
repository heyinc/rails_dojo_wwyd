class Payment < ApplicationRecord
  belongs_to :order

  validates :payment_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }

  def pay!(token:)
    results = PaymentApiClient.execute(token:, amount:)
    self.payment_id = results[:payment_id]

    save!
  end
end
