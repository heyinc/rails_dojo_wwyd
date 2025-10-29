class Order < ApplicationRecord
  belongs_to :reservation
  belongs_to :user

  validates :email, presence: true
  validates :name, presence: true
  validates :product, presence: true
end
