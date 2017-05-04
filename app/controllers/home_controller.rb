class HomeController < ApplicationController
  def show
    redirect_to campaigns_path if current_user
  end
end
