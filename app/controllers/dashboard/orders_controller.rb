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
    new_resources_setup
  end

  def create
    reservation = Reservation.find(params.dig(:order, :reservation_id))
    item = Item.find(params.dig(:order, :item_id))
    @order = Order.new(order_params(reservation, item))

    if @order.save
      redirect_to dashboard_orders_path, notice: '注文が作成されました'
    else
      new_resources_setup
      flash.alert.now = @order.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  private

  def new_resources_setup
    @items = Item.all.order(:name)
    @users = User.all.order(:name)
  end

  def order_params(reservation, item)
    params.require(:order)
      .permit(:reservation_id, :user_id, :item_id, :email, :name, :item_id)
      .merge(name: item.name, email: reservation.email)
  end
end
