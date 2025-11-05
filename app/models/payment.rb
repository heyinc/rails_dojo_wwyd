class Payment < ApplicationRecord
  belongs_to :order

  validates :payment_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
end
