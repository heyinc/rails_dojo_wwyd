class Order < ApplicationRecord
  belongs_to :reservation
  belongs_to :user
  belongs_to :item

  validates :email, presence: true
  validates :name, presence: true
end
