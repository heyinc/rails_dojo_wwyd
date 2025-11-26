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
    reservation = Reservation.find(params[:order][:reservation_id])
    item = Item.find(params[:order][:item_id])

    if reservation.completed?
      flash[:alert] = "この予約はすでに処理済みです。"
      return redirect_to dashboard_orders_path
    end

    if item.stock < 1
      @order = Order.new(order_params)
      @order.name = item.name
      flash.now[:alert] = "在庫が不足しています。"
      @items = Item.all.order(:name)
      @users = User.all.order(:name)
      return render :new
    end

    @order = Order.new(order_params)
    @order.name = item.name

    begin
      Order.transaction do
        @order.save!

        # 決済APIを実行
        token = params[:order][:token]
        amount = item.price
        payment_result = PaymentApiClient.execute(token: token, amount: amount)

        # Paymentレコードを作成
        @order.create_payment!(
          payment_id: payment_result[:payment_id],
          amount: payment_result[:amount]
        )

        reservation.update!(status: :completed)

        # 在庫数を1減らす
        item.decrement!(:stock)
      end

      redirect_to dashboard_orders_path, notice: "注文が作成されました"
    rescue ActiveRecord::RecordInvalid
      @items = Item.all.order(:name)
      @users = User.all.order(:name)
      render :new
    end
  end

  private

  def order_params
    params.require(:order).permit(:reservation_id, :user_id, :item_id, :email)
  end
end
