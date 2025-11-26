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
    prepare_form_data # Refactored
  end

  def create
    @order = Order.new(order_params)
    reservation = Reservation.find(@order.reservation_id)
    item = Item.find(@order.item_id)

    @order.email = reservation.email
    @order.name = item.name

    if reservation.status == "completed"
      flash.now[:alert] = "予約は既に完了しています"
      prepare_form_data
      render :new, status: :unprocessable_entity
      return
    end

    ActiveRecord::Base.transaction do
      locked_item = Item.lock.find(item.id)

      raise "商品の在庫がありません" if locked_item.stock < 1

      @order.save!

      payment_result = PaymentApiClient.execute(
        token: params[:order][:token],
        amount: locked_item.price
      )

      @order.create_payment!(
        amount: payment_result[:amount],
        payment_id: payment_result[:payment_id]
      )

      reservation.update!(status: "completed")
      locked_item.update!(stock: locked_item.stock - 1)
    end

    redirect_to dashboard_orders_path, notice: "注文が作成されました"

  rescue ActiveRecord::RecordInvalid
    prepare_form_data
    render :new, status: :unprocessable_entity
  rescue Timeout::Error
    flash.now[:alert] = "決済処理がタイムアウトしました。しばらく待ってから再度お試しください。"
    prepare_form_data
    render :new, status: :unprocessable_entity
  rescue RuntimeError => e
    if e.message == "商品の在庫がありません"
      flash.now[:alert] = e.message
      prepare_form_data
      render :new, status: :unprocessable_entity
    else
      raise e
    end
  end

  def destroy
    order = Order.find(params[:id])
    reservation = order.reservation
    item = order.item

    ActiveRecord::Base.transaction do
      # Prevent deadlock: Lock order must match create action (Item -> Reservation)
      item.lock!
      reservation.lock!

      reservation.update!(status: "pending")
      item.update!(stock: item.stock + 1)

      order.destroy!
    end

    redirect_to dashboard_orders_path, notice: "注文をキャンセルしました"
  end

  private

  def order_params
    params.require(:order).permit(:reservation_id, :item_id, :user_id)
  end

  def prepare_form_data
    @items = Item.all.order(:name)
    @users = User.all.order(:name)
  end
end
