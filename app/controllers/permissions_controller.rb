class PermissionsController < ApplicationController
	before_action :require_login

	def create
		campaign = Campaign.find(params[:campaign_id])
		if current_user.can_edit?(campaign)
			Permission.create!(email: params[:email], campaign_id: params[:campaign_id], level: "user")
		end
		redirect_to campaign_path(params[:campaign_id])
	end
end
