class Dashboard::ReservationsController < ApplicationController
  def index
    @reservations = Reservation.all.order(created_at: :desc)
  end

  def show
    @reservation = Reservation.find(params[:id])
  end
end
