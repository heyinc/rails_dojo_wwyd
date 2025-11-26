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

    if reservation.order.present?
      flash.alert = "注文はすでに存在します"
      redirect_to new_dashboard_order_path(reservation_id: reservation.id)
      return
    end

    if item.stock <= 0
      flash.alert = "選択した商品は在庫切れです"
      redirect_to new_dashboard_order_path(reservation_id: reservation.id)
      return
    end

    order = Order.new(
      reservation: reservation,
      email: reservation.email,
      name: item.name,
      user: Current.user,
      item: item,
    )

    unless order.save
      @order = order
      @items = Item.all.order(:name)
      @users = User.all.order(:name)
      flash.alert = order.errors.full_messages.join(", ")
      redirect_to new_dashboard_order_path(reservation_id: reservation.id)
      return
    end

    begin
      payment_api_client = PaymentApiClient.execute(
        token: params[:order][:token],
        amount: item.price
      )
    rescue Timeout::Error
      # NOTE: 決済に失敗した場合に……
      #   * Orderも削除すべき？
      #   * item.stockは減らすべき？(注文のみ保存して決済は後でやり直す？)
      flash.alert = "決済処理がタイムアウトしました"
      redirect_to new_dashboard_order_path(reservation_id: reservation.id)
      return
    end

    payment = Payment.new(
      amount: payment_api_client[:amount],
      payment_id: payment_api_client[:payment_id],
      order: order,
    )

    ApplicationRecord.transaction do
      payment.save!
      reservation.update!(status: "completed")
      item.decrement!(:stock)
    end

    if payment.persisted?
      redirect_to dashboard_orders_path, notice: "注文が作成されました"
      return
    else
      # TODO
      flash.alert = "なんらかの理由で決済に失敗しました"
      redirect_to new_dashboard_order_path(reservation_id: reservation.id)
      return
    end
    redirect_to dashboard_orders_path, notice: "注文が作成されました"
  end
end
