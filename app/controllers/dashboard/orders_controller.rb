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
    order_params = params.expect(order: %i[reservation_id item_id user_id token])

    reservation = Reservation.find(order_params[:reservation_id])
    item = Item.find(order_params[:item_id])
    user = User.find(order_params[:user_id])

    reservation.transaction do
      item.lock!
      reservation.lock!

      reservation.complete!
      item.consume_stock!

      # TODO: トランザクションは確定していないので Payment Request が成功しているにもかかわらず注文が作成されないケースがある
      payment = PaymentApiClient.execute(token: order_params[:token], amount: item.price)
      Order.create!(user:, item:, reservation:, payment:, email: reservation.email, name: item.name)
    end

    flash.notice = "注文が作成されました"
    redirect_to dashboard_orders_path
  rescue Reservation::AlreadyCompleted
    # TODO: new_dashboard_orders_path を表示したい
    flash.notice = "既に確定された予約です"
    redirect_to dashboard_orders_path
  rescue Item::LackOfStock
    # TODO: new_dashboard_orders_path を表示したい
    flash.notice = "商品の在庫が不足しています"
    redirect_to dashboard_orders_path
  rescue PaymentApiClient::Timeout
    # TODO: new_dashboard_orders_path を表示したい
    flash.notice = "決済がタイムアウトしました"
    redirect_to dashboard_orders_path
  end
end
