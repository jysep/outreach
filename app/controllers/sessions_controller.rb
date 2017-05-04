class SessionsController < ApplicationController
  def create
    p request.env["omniauth.auth"]
    user = User.from_omniauth(request.env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to campaigns_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
