class EntriesController < ApplicationController
	before_action :require_login, except: [:index, :submit]
	skip_before_action :verify_authenticity_token, only: [:submit]

	def show
		@entry = Entry.find(params[:id])
		@campaign = @entry.campaign
		unless @campaign.permissions.where(email: current_user.email).exists?
			redirect_to '/'
		end
	end

	def index
		begin
			@campaign = Campaign.find(entry_params[:campaign_id])
		rescue ActiveRecord::RecordNotFound
			redirect_to '/'
		end
	end

	def submit
		successes = {}
		submitparams = params.permit(:entries, :campaign_id)
		params[:entries].each do |entry|
			data = entry.require(:entry).permit(
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
				:themes => [],
			)
			data[:campaign_id] = params[:campaign_id]
			data[:user_email] = current_user.email if current_user
			if Entry.create(data)
				successes[entry[:timestamp]] = true
			end
		end
		render json: {successes: successes}
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
