class CampaignsController < ApplicationController
	before_action :require_login

	def new
	end

	def index
		@user_campaigns = current_user.campaigns.order(created_at: :desc).to_a
	end

	def create
		Campaign.transaction do
			campaign = Campaign.create!(name: params[:name])
			campaign.permissions.create!(email: current_user.email, level: "owner")
		end
		redirect_to action: :index
	end

	def show
		@campaign = Campaign.find(params[:id])
		@entries = @campaign.entries.order(created_at: :desc).to_a
		@role = @campaign.permissions.where(email: current_user.email).take.level
	end

	def destroy
	end
end
