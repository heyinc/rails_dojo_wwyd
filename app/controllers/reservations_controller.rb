class ReservationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @reservation = Reservation.new
  end

  def create
    @reservation = Reservation.new(reservation_params)

    if @reservation.save
      redirect_to root_path, notice: "予約が完了しました。"
    else
      render :new, status: :unprocessable_entity
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
