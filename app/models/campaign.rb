class Campaign < ApplicationRecord
	before_create { self.id = SecureRandom.base58(24) }

	has_many :permissions, dependent: :destroy
	has_many :entries, dependent: :destroy
	has_many :duplicates, dependent: :destroy

	def check_duplicates
		return unless unchecked_duplicates?
		potentials = entries.select(:street_number, :unit_number)
			.group(:street_number, :unit_number)
			.having("COUNT(*)>1 AND (? IS NULL OR MAX(updated_at)>?)", last_duplicate_check, last_duplicate_check)
		potentials.each do |potential|
			Duplicate.create_for_entries(id, potential)
		end
	end

	def unchecked_duplicates?
		entries.exists? && (last_duplicate_check.nil? || entries.maximum(:updated_at) > last_duplicate_check)
	end
end
