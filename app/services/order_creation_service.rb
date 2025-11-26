class OrderCreationService
  def initialize(order_params:, token:)
    @order_params = order_params
    @token = token
  end

  def call
    reservation = Reservation.find(@order_params[:reservation_id])
    item = Item.find(@order_params[:item_id])

    validate_preconditions!(reservation, item)

    order = build_order(item)

    Order.transaction do
      order.save!

      # 決済APIを実行
      payment_result = PaymentApiClient.execute(token: @token, amount: item.price)

      # Paymentレコードを作成
      order.create_payment!(
        payment_id: payment_result[:payment_id],
        amount: payment_result[:amount]
      )

      reservation.update!(status: :completed)

      # 在庫数を1減らす
      item.decrement!(:stock)
    end

    order
  end

  private

  def validate_preconditions!(reservation, item)
    if reservation.completed?
      raise ReservationAlreadyCompletedError, "この予約はすでに処理済みです。"
    end

    if item.stock < 1
      raise InsufficientStockError, "在庫が不足しています。"
    end
  end

  def build_order(item)
    order = Order.new(@order_params)
    order.name = item.name
    order
  end

  class ReservationAlreadyCompletedError < StandardError; end
  class InsufficientStockError < StandardError; end
end
