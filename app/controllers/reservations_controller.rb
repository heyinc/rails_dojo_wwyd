class ReservationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @reservation = Reservation.new
    @users = User.all.order(:name)
  end

  def create
    @reservation = Reservation.new(reservation_params)

    if params[:reservation][:preferred_staff_user_id].present?
      user = User.find_by(id: params[:reservation][:preferred_staff_user_id])
      @reservation.preferred_staff = user&.name
    end

    if @reservation.save
      redirect_to root_path, notice: "予約が完了しました。"
    else
      @users = User.all.order(:name)
      flash.now.alert = @reservation.errors.full_messages.join(", ")
      render :new
    end
  end

  private

  def reservation_params
    params
      .require(:reservation)
      .permit(:email, :name, :date, :time, :preferred_staff, :purchase_intention)
      .transform_values(&:strip)
  end
end
