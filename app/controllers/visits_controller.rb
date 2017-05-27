class VisitsController < ApplicationController
	before_action :require_login

	def edit
		@visit = Visit.find(params[:id])
		@entry = @visit.entry
		@visit_num = @entry.visits.where("(date, created_at) < (?, ?)", @visit.date, @visit.created_at).count+1
		unless current_user.can_see?(@visit.entry.campaign)
			redirect_to '/'
			return
		end
	end

	def update
		@visit = Visit.find(params[:id])
		unless current_user.can_see?(@visit.entry.campaign)
			redirect_to '/'
			return
		end

		@visit.update(visit_params)
		redirect_to controller: :entries, action: :show, id: @visit.entry_id
	end

	def visit_params
		params.permit(
			:team,
			:date,
			:time,
			:outcome,
			:notes,
			:themes => [],
		)
	end
end
