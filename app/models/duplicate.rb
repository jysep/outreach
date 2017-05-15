class Duplicate < ApplicationRecord
	belongs_to :campaign
	belongs_to :entry1, class_name: "Entry", foreign_key: "entry1_id"
	belongs_to :entry2, class_name: "Entry", foreign_key: "entry2_id"

	def self.create_for_entries(campaign_id, entry)
		ids = Entry.where(
			street_number: entry[:street_number],
			unit_number: entry[:unit_number])
			.order(id: :asc)
			.pluck(:id)
		ids.combination(2).each do |pair|
			Duplicate.where(
				campaign_id: campaign_id,
				entry1_id: pair.first,
				entry2_id: pair.last)
				.first_or_create(status: "potential")
		end
	end

	def team
		@team ||= entry1.team + "; " + entry2.team
	end

	def street
		entry1.street
	end

	def street_number
		entry1.street_number
	end

	def unit_number
		entry1.unit_number
	end

	def outcome
		if ["1", "2"].include?(entry2.outcome)
			entry1.outcome
		else
			entry2.outcome
		end
	end

	def people
		@people ||= [entry1.people, entry2.people].select{|p| !p.blank?}.join("; ")
	end

	def contact
		@contact ||= [entry1.contact, entry2.contact].select{|c| !c.blank?}.join("; ")
	end

	def age_groups
		@age_groups ||= entry1.age_groups + entry2.age_groups
	end

	def themes
		@themes ||= entry1.themes + entry2.themes
	end

	def notes
		@notes ||= [entry1.notes, entry2.notes].select{|n| !n.blank?}.join("\n\n")
	end
end
