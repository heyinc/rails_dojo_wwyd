# このクラスが決済APIを実行するクラスだと思って使ってください
class PaymentApiClient
  class Timeout < ::Timeout::Error
  end

  class << self
    # @param token [String] トークン
    # @param amount [Integer] 決済金額
    # @return [Hash] 決済結果 { payment_id: String, amount: Integer }
    def execute(token:, amount:)
      raise ArgumentError, "token is required" if token.blank?

      # APIコールなので時折タイムアウトが発生します
      raise Timeout, "Payment API request timed out" if rand(100000) == 0

      Payment.build(
        payment_id: generate_payment_id,
        amount: amount.to_i
      )
    end

    private

    def generate_payment_id
      timestamp = Time.current.strftime("%Y%m%d")
      random_string = SecureRandom.alphanumeric(9).upcase
      "PAY_#{timestamp}_#{random_string}"
    end
  end
end
