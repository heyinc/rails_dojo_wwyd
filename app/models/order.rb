class Order < ApplicationRecord
  belongs_to :reservation
  belongs_to :user
  belongs_to :item
  has_one :payment, dependent: :destroy

  validates :email, presence: true
  validates :name, presence: true

  before_validation do
    self.email = reservation&.email
    self.name = item&.name
  end
end
