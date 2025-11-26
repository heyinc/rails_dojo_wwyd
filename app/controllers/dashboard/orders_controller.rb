class Dashboard::OrdersController < ApplicationController
  before_action :set_items_and_users, only: [ :new, :create ]

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
    user = User.find(order_params[:user_id])

    @order = reservation.build_order(
      email: reservation.email,
      name: item.name,
      user: user,
      item: item,
    )

    if item.stock < 1
      flash.now.alert = "在庫が不足しています"
      return render :new
    end

    if @order.execute_payment_and_update_reservation_and_item(token: order_params[:token])
      redirect_to dashboard_orders_path, notice: "注文が作成されました"
    else
      flash.now.alert = "決済に失敗しました。"
      render :new
    end
  end

  private

  def order_params
    params.require(:order).permit(:reservation_id, :item_id, :user_id, :token)
  end

  def set_items_and_users
    @items = Item.all.order(:name)
    @users = User.all.order(:name)
  end
end
