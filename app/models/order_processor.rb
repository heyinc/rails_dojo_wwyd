class OrderProcessor
  class Result
    attr_reader :error

    def initialize(error:)
      @error = error
    end

    def success?
      error.nil?
    end
  end

  class << self
    def execute(reservation:, item:, user:, token:)
      order = Order.create!(
        reservation: reservation,
        email: reservation.email,
        item: item,
        name: item.name,
        user: Current.user
      )
      Payment.process_payment!(order:, item:, token:)
      reservation.mark_as_completed!
      item.decrement_stock!
      Result.new(error: nil)
    rescue Reservation::AlreadyCompletedError => e
      Result.new(error: e)
    rescue Item::OutOfStockError
      Result.new(error: e)
    end
  end
end
