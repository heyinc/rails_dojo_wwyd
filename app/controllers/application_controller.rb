class ApplicationController < ActionController::Base
  include Authentication
  allow_browser versions: :modern

  stale_when_importmap_changes

  rescue_from ActiveRecord::RecordNotFound do
    render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
  end
end
