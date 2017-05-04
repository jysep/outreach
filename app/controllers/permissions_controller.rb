class PermissionsController < ApplicationController
	def create
		if Permission.where(email: current_user.email, campaign_id: params[:campaign_id], level: "owner").exists?
			Permission.create!(email: params[:email], campaign_id: params[:campaign_id])
		end
		redirect_to campaign_path(params[:campaign_id])
	end
end
