class Entry < ApplicationRecord
	AGE_GROUPS = {
		"1" => "Children",
		"2" => "Junior Youth",
		"3" => "Youth"
	}

	belongs_to :campaign
	has_many :duplicates, foreign_key: :entry1_id, dependent: :destroy
	has_many :more_duplicates, class_name: "Duplicate", foreign_key: :entry2_id, dependent: :destroy
	has_many :visits, -> { order(date: :desc, created_at: :desc) }, dependent: :destroy
	validates :street, presence: true
	validates :street_number, presence: true
	validates :last_outcome, presence: true, inclusion: { in: Visit::OUTCOMES.keys }
	validates :last_visit, presence: :true
	validate :validate_age_groups

	before_save :uniq_arrays

	def validate_age_groups
		if !age_groups.is_a?(Array) || age_groups.detect{|a| !AGE_GROUPS.keys.include?(a)}
			errors.add(:age_groups, :invalid)
		end
	end

	def uniq_arrays
		self.age_groups.uniq!
	end

	def full_address
		"#{street_number} #{street}" + (unit_number.blank? ? "" : " ##{unit_number}")
	end

	def last_outcome_text
		Visit::OUTCOMES[last_outcome]
	end

	def all_themes
		visits.flat_map{|v| v.themes}.uniq.sort
	end

	def all_notes
		visits.map{|v| v.notes}.select(&:present?).join("\n\n")
	end

	def all_teams
		visits.map{|v| v.team}.select(&:present?).uniq.join("; ")
	end
end
