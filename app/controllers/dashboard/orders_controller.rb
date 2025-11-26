class Dashboard::OrdersController < ApplicationController
  def index
    @orders = Order.includes(:item, :reservation, :user).order(created_at: :desc)
  end

  def new
    @reservation = Reservation.find(params[:reservation_id])
    render_new
  end

  def create
    @reservation = Reservation.find(order_params[:reservation_id])
    item = Item.find(order_params[:item_id])
    result = OrderProcessor.execute(reservation: @reservation, item:, user: Current.user, token: order_params[:token])
    if result.success?
      redirect_to dashboard_orders_path, notice: "注文が作成されました"
    else
      flash.now[:alert] = "注文の作成に失敗しました"
      render_new
    end
  end

  private

    def order_params
      params.require(:order).permit(:reservation_id, :item_id, :user_id, :token)
    end

    def render_new
      @order = Order.new(
        reservation: @reservation,
        email: @reservation.email,
        name: @reservation.name,
        user: Current.user
      )
      @items = Item.all.order(:name)
      @users = User.all.order(:name)
      render :new
    end
end
