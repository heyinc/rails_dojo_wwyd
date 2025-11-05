class Order < ApplicationRecord
  belongs_to :reservation
  belongs_to :user
  belongs_to :item
  has_one :payment, dependent: :destroy

  validates :email, presence: true
  validates :name, presence: true
end
