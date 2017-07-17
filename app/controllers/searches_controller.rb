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
		@entries = @campaign.entries.joins(:visits)
		if params[:keywords].present?
			keywords = params[:keywords].split(" ")
			keyword_params = {}
			pnum = 0
			keyword_query = keywords.map do |k|
				pname = "param#{pnum}"
				keyword_params[pname.to_sym] = "%#{k}%"
				"(" + SEARCH_FIELDS.map do |f|
					"#{f} LIKE :#{pname}"
				end.join(" OR ") + ")"
			end.join(" AND ")
			@entries = @entries.where(keyword_query, keyword_params)
		end
		@entries = @entries.where("entries.age_groups @> ARRAY[?]", params[:age_group]) unless params[:age_group].blank?
		if params[:outcomes].present?
			@entries = @entries.where("entries.last_outcome IN (?)", params[:outcomes])
		end
	end
end
