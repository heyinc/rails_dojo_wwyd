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
    permitted_params = params.expect(order: [ :reservation_id, :user_id, :item_id ])
    reservation = Reservation.find(permitted_params[:reservation_id])
    item = Item.find(permitted_params[:item_id])

    order = reservation.create_order(
      email: reservation.email,
      item_id: item.id,
      name: item.name,
      user_id: permitted_params[:user_id] # user_idはforeign key制約あり
    )
    # TODO: まだpaymentがくっついてない
    if order.id # TODO: かっこ悪い
      redirect_to dashboard_orders_path, notice: "注文が作成されました"
    else
      render :new
    end
  end
end
