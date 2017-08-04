class Duplicate < ApplicationRecord
	belongs_to :campaign
	belongs_to :entry1, class_name: "Entry", foreign_key: "entry1_id"
	belongs_to :entry2, class_name: "Entry", foreign_key: "entry2_id"

	def self.create_for_entries(campaign_id, entry)
		ids = Entry.where(
			street_number: entry[:street_number],
			unit_number: entry[:unit_number],
			campaign_id: campaign_id)
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

	def visits
		@visits ||= (entry1.visits + entry2.visits).sort_by {|v| v.date}.reverse
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
		if ["1", "2", "3"].include?(entry2.last_outcome)
			entry1.last_outcome
		else
			entry2.last_outcome
		end
	end

	def people
		@people ||= [entry1.people, entry2.people].select(&:present?).join("; ")
	end

	def contact
		@contact ||= [entry1.contact, entry2.contact].select(&:present?).join("; ")
	end

	def age_groups
		@age_groups ||= entry1.age_groups + entry2.age_groups
	end
end
