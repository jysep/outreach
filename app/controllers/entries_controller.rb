class EntriesController < ApplicationController
	before_action :require_login, except: [:index, :submit]
	skip_before_action :verify_authenticity_token, only: [:submit]

	def show
		@entry = Entry.find(params[:id])
		@visits = @entry.visits.to_a
		@campaign = @entry.campaign
		unless current_user.can_see?(@campaign)
			redirect_to '/'
			return
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
		params[:entries].each do |record|
			entry = Entry.new(submit_entry_params(record))
			entry.campaign_id = params[:campaign_id]
			entry.user_email = current_user.email if current_user

			visit = Visit.new(submit_visit_params(record))
			entry[:last_outcome] = visit.outcome
			entry[:last_visit] = visit.date

			Entry.transaction do
				if entry.save
					entry.visits << visit
					visit.save
					successes[record[:timestamp]] = true
				end
			end
		end
		render json: {successes: successes}
	end

	def edit
		@entry = Entry.find(params[:id])
		@visits = @entry.visits
		@campaign = @entry.campaign
		unless current_user.can_see?(@campaign)
			redirect_to '/'
			return
		end
	end

	def update
		@entry = Entry.find(params[:id])
		unless current_user.can_see?(@entry.campaign)
			redirect_to '/'
			return
		end

		@entry.update!(entry_params)
		redirect_to action: :show, id: params[:id]
	end

	def destroy
	end

	def submit_entry_params(entry)
		entry.require(:entry).permit(
			:street,
			:street_number,
			:unit_number,
			:people,
			:contact,
			:age_groups => [],
		)
	end

	def submit_visit_params(entry)
		entry.require(:entry).permit(
			:team,
			:date,
			:time,
			:outcome,
			:notes,
			:themes => [],
		)
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
