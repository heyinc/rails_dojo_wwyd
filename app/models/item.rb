class Item < ApplicationRecord
  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
