class Dashboard::Order < ::Order
  class << self
    def model_name = ::Order.model_name
  end

  attribute :token
  validates :token, presence: true

  before_validation :to_completed_status
  before_validation :decrease_stock
  after_save :create_payment
  after_save do
    reservation.save!
    item.save!
  end

  private

  def amount = 1

  def to_completed_status
    reservation&.status = :completed
  end

  def decrease_stock
    item&.stock -= amount
  end

  def create_payment
    result = PaymentApiClient.execute(token:, amount:)
    payment_id = result[:payment_id]

    create_payment!(payment_id:, amount:)
  end
end
