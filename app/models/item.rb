class Item < ApplicationRecord
  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }

  class OutOfStockError < StandardError; end

  def decrement_stock!
    with_lock do
      raise OutOfStockError if stock < 1

      update!(stock: stock - 1)
    end
  end
end
