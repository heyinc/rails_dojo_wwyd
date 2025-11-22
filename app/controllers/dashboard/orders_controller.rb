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
    reservation = Reservation.find(params.expect(order: :reservation_id)[:reservation_id])
    @order = Dashboard::Order.new(reservation, order_params)

    if @order.save
      redirect_to dashboard_orders_path, notice: "Order was successfully created."
    else
      @items = Item.all.order(:name)
      @users = User.all.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.expect(order: %i[email name item_id user_id token])
  end
end
