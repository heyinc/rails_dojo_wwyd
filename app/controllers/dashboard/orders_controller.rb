class Dashboard::OrdersController < ApplicationController
  def index
    @orders = Order.includes(:item, :reservation, :user).order(created_at: :desc)
  end

  def new
    reservation = Reservation.find(params[:reservation_id])
    @order = Order.new(
      reservation: reservation,
      email: reservation.email,
      name: reservation.name,
      user: Current.user
    )
    @items = Item.all.order(:name)
    @users = User.all.order(:name)
  end

  def create
    @order = Order.new(order_params)

    if @order.reservation.status == :completed
      flash.now.alert = "すでに作成済み"
      return render :new
    end

    if @order.save
      # 決済APIを実行
      token = params[:order][:token]
      amount = @order.item.price
      payment_result = PaymentApiClient.execute(token: token, amount: amount)

      # Paymentレコードを作成
      @order.create_payment!(
        payment_id: payment_result[:payment_id],
        amount: payment_result[:amount]
      )

      @order.reservation.update(status: :completed)

      redirect_to dashboard_orders_path, notice: "注文が作成されました"
    else
      @items = Item.all.order(:name)
      @users = User.all.order(:name)
      render :new
    end
  end

  private

  def order_params
    params.require(:order).permit(:reservation_id, :user_id, :item_id, :email, :name)
  end
end
