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
    reservation = Reservation.find(order_params[:reservation_id])
    item = Item.find(order_params[:item_id])

    if item.stock < 1
      @items = Item.all.order(:name)
      @users = User.all.order(:name)
      @order = Order.new(
        reservation: reservation,
        email: reservation.email,
        name: reservation.name,
        user: Current.user
      )

      flash.now.alert = "在庫が不足しています"
      return render :new
    end

    user = User.find(order_params[:user_id])

    order = reservation.build_order(
      email: reservation.email,
      name: item.name,
      user: user,
      item: item,
    )

    begin
      response = PaymentApiClient.execute(token: order_params[:token], amount: order.item.price)
    rescue
      @items = Item.all.order(:name)
      @users = User.all.order(:name)
      flash.now.alert = "決済に失敗しました。"
      return render :new
    end

    order.build_payment(payment_id: response[:payment_id], amount: response[:amount])

    order.save!
    reservation.update!(status: :completed)

    item.update!(stock: item.stock - 1)

    redirect_to dashboard_orders_path, notice: "注文が作成されました"
  end

  private

  def order_params
    params.require(:order).permit(:reservation_id, :item_id, :user_id, :token)
  end
end
