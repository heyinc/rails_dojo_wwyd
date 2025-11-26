class Item < ApplicationRecord
  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }

  class LackOfStock < StandardError
  end

  def consume_stock!(num: 1)
    raise LackOfStock if stock - num <= 0

    update!(stock: self.stock - num)
  end
end
