class SearchesController < ApplicationController
	SEARCH_FIELDS = ["entries.street", "entries.people", "entries.contact", "visits.notes", "visits.team"]

	def new
		@campaign = Campaign.find(params[:campaign_id])
		unless current_user.can_see?(@campaign)
			redirect_to '/'
			return
		end
	end

	def show
		@campaign = Campaign.find(params[:campaign_id])
		unless current_user.can_see?(@campaign)
			redirect_to '/'
			return
		end
		@entries = @campaign.entries.joins(:visits).order(last_visit: :desc, street: :desc, street_number: :desc, unit_number: :desc)
		if params[:keywords].present?
			keywords = params[:keywords].split(" ")
			keyword_params = {}
			pnum = 0
			keyword_query = keywords.map do |k|
				pname = "param#{pnum}"
				keyword_params[pname.to_sym] = "%#{k}%"
				"(" + SEARCH_FIELDS.map do |f|
					"#{f} ILIKE :#{pname}"
				end.join(" OR ") + ")"
			end.join(" AND ")
			@entries = @entries.where(keyword_query, keyword_params)
		end
		@entries = @entries.where("entries.age_groups @> ARRAY[?]", params[:age_group]) unless params[:age_group].blank?
		if params[:outcomes].present?
			@entries = @entries.where("entries.last_outcome IN (?)", params[:outcomes])
		end
		@entries = @entries.to_a.uniq
	end
end
