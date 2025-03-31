class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def hello_world
    message = Message.last
    if message
      render json: message, status: :ok
    else
      render json: { status: "ok" }, status: :ok
    end
  end
end
