require 'csv'

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
		unless current_user.can_see?(@campaign)
			redirect_to '/'
			return
		end
		@entries = @campaign.entries.order(date: :desc, team: :desc, street: :desc, street_number: :desc, unit_number: :desc).to_a
		@role = @campaign.permissions.where(email: current_user.email).take.level
		@campaign.check_duplicates
		@duplicate_count = @campaign.duplicates.where(status: "potential").count
	end

	def export
		@campaign = Campaign.find(params[:id])
		unless current_user.can_see?(@campaign)
			redirect_to '/'
			return
		end
		@entries = @campaign.entries.order(created_at: :desc).to_a

		csv_data = CSV.generate do |csv|
		  csv << ["Date", "Team", "Street", "Street Number", "Unit", "Outcome", "People", "Contact", "Age Groups", "Themes", "Notes"]
		  @entries.each do |entry|
				csv << [
					entry.date,
					entry.team,
					entry.street,
					entry.street_number,
					entry.unit_number,
					Entry::OUTCOMES[entry.outcome],
					entry.people,
					entry.contact,
					entry.age_groups.map{|a| Entry::AGE_GROUPS[a]}.join(", "),
					entry.themes.map{|t| Entry::THEMES[t]}.join(", "),
					entry.notes
				]
			end
		end

		filename = @campaign.name.gsub(/[^ A-Za-z0-9]/, "").gsub(" ","-").downcase+".csv"
		send_data(csv_data,
		  :filename => filename,
		  :type => "text/csv")
	end

	def destroy
	end
end
