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
    service = OrderCreationService.new(
      order_params: order_params,
      token: params[:order][:token]
    )

    begin
      @order = service.call
      redirect_to dashboard_orders_path, notice: "注文が作成されました"
    rescue OrderCreationService::ReservationAlreadyCompletedError => e
      flash[:alert] = e.message
      redirect_to dashboard_orders_path
    rescue OrderCreationService::InsufficientStockError => e
      @order = Order.new(order_params)
      @order.name = Item.find(params[:order][:item_id]).name
      flash.now[:alert] = e.message
      @items = Item.all.order(:name)
      @users = User.all.order(:name)
      render :new
    rescue ActiveRecord::RecordInvalid
      @items = Item.all.order(:name)
      @users = User.all.order(:name)
      render :new
    end
  end

  private

  def order_params
    params.require(:order).permit(:reservation_id, :user_id, :item_id, :email)
  end
end
