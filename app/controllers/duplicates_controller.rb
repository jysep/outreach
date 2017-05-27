class DuplicatesController < ApplicationController
	before_action :require_login
	before_action :authz_check

	def index
		@duplicates = @campaign.duplicates.where(status: "potential").includes(:entry1, :entry2).to_a
		if @duplicates.empty?
			redirect_to campaign_path(@campaign.id)
		end
	end

	def show
		@duplicate = Duplicate.where(id: params[:id]).includes(:entry1, :entry2).take
	end

	def merge
		@duplicate = Duplicate.find(params[:id])
		Duplicate.transaction do
			@duplicate.entry2.visits.update_all(entry_id: @duplicate.entry1.id)
			@duplicate.entry1.update(duplicate_params.merge({
				last_visit: @duplicate.visits.first.date,
				last_outcome: @duplicate.outcome
			}))
			@duplicate.entry2.destroy
		end
		redirect_to action: :index, campaign_id: params[:campaign_id]
	end

	def reject
		@duplicate = Duplicate.find(params[:id])
		@duplicate.update(status: "rejected")
		redirect_to action: :index, campaign_id: params[:campaign_id]
	end

	private

	def campaign
		@campaign ||= Campaign.find(params[:campaign_id])
	end

	def authz_check
		unless current_user.can_see?(campaign)
			redirect_to '/'
		end
	end

	def duplicate_params
		params.permit(
			:street,
			:street_number,
			:unit_number,
			:people,
			:contact,
			:age_groups => [],
		)
	end
end
