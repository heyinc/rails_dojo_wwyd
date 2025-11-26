class Dashboard::Order < ::Order
  class << self
    def model_name = ::Order.model_name
  end

  attribute :token
  validates :token, presence: true
  validate :reservation_must_be_pending
  validate :item_must_have_stock

  before_validation :set_email
  before_validation :set_name
  after_validation :to_completed_status
  after_validation :decrease_stock
  after_save :create_payment
  after_save do
    reservation.save!
    item.save!
  end

  private

  def reservation_must_be_pending
    return unless reservation

    if reservation.status == "completed"
      errors.add(:reservation, "は既に注文済みです")
    end
  end

  def item_must_have_stock
    return unless item

    if item.stock <= 0
      errors.add(:item, "の在庫が不足しています")
    end
  end

  def set_email = self.email = reservation.email

  def set_name = self.name = item.name

  def to_completed_status
    reservation&.status = :completed
  end

  def decrease_stock
    item&.stock -= 1
  end

  def create_payment
    result = PaymentApiClient.execute(token:, amount: item.price)

    create_payment!(payment_id: result[:payment_id], amount: result[:amount])
  end
end
