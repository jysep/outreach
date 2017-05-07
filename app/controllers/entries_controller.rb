class EntriesController < ApplicationController
	before_action :require_login, except: [:index, :create]

	def show
	end

	def index
		@campaign = Campaign.find(entry_params[:campaign_id])
	end

	def create
		vals = entry_params
		if current_user
			vals[:user_email] = current_user.email
		end
		vals[:age_groups] = vals[:age_groups].join(",") unless vals[:age_groups].nil?
		vals[:themes] = vals[:themes].join(",") unless vals[:themes].nil?
		Entry.create!(vals)
		redirect_to action: :index
	end

	def update
	end

	def destroy
	end

	def entry_params
		params.permit(
			:campaign_id,
			:team,
			:date,
			:time,
			:street,
			:street_number,
			:unit_number,
			:outcome,
			:people,
			:contact,
			:notes,
			:age_groups => [],
			:themes => []
		)
	end
end
