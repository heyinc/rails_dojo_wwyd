class Dashboard::ReservationsController < ApplicationController
  def index
    @reservations = Reservation.all.order(created_at: :desc)
  end
end
