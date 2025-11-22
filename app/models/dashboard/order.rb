class Dashboard::Order < ActiveRecordCompose::Model
  class << self
    def self.model_name = ::Order.model_name
  end

  def initialize(reservation, attributes = {})
    @reservation = reservation
    reservation.build_order
    models << reservation << order
    super(attributes)
  end

  attr_reader :reservation

  attribute :token
  validates :token, presence: true

  before_validation :to_completed_status
  before_validation :decrease_stock
  after_save :create_payment

  delegate_attribute :email, :name, :item_id, :user_id, to: :order

  private

  delegate :order, to: :reservation, private: true
  delegate :item, to: :order, private: true

  def amount = 1

  def to_completed_status
    reservation.status = :completed
  end

  def decrease_stock
    return unless item

    item.stock -= amount
    models << item
  end

  def create_payment
    result = PaymentApiClient.execute(token:, amount:)
    payment_id = result[:payment_id]

    order.create_payment!(payment_id:, amount:)
  end
end
