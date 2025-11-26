class Dashboard::OrdersController < ApplicationController
  include OrderInputHandler

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
    order, payment = build_order_and_payment

    ActiveRecord::Base.transaction do
      payment.pay!(token:) &&
        order.save! &&
        order.reservation.completed! &&
        order.item.decrease_stock
    end

    redirect_to dashboard_orders_path, notice: "注文が作成されました"
  end

  private

  def token = params.dig(:order, :token)
end
