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
    order = Order.new(
      reservation: reservation,
      email: reservation.email,
      name: item.name,
      user: Current.user,
      item: item,
    )
    if order.save
      redirect_to dashboard_orders_path, notice: "注文が作成されました"
    else
      @order = order
      @items = Item.all.order(:name)
      @users = User.all.order(:name)
      flash.now.alert = order.errors.full_messages.join(", ")
      render :new
    end
  end
end
