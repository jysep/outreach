class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user

  def current_user
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue ActiveRecord::RecordNotFound
      @current_user = nil
      session.delete(:user_id,)
    end
  end

  def require_login
    unless current_user
      redirect_to root_path
    end
  end
end
