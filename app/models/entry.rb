class Entry < ApplicationRecord
	OUTCOMES = ["not home", "not visited", "no answer", "not interested", "interested"]
	AGE_GROUPS = ["1", "2", "3"]
	THEMES = (1..13).map {|i| "#{i}"}

	belongs_to :campaign
	validates :team, presence: true
	validates :date, presence: true
	validates :street, presence: true
	validates :street_number, presence: true
	validates :outcome, presence: true, inclusion: { in: OUTCOMES }
	validate :validate_age_groups
	validate :validate_themes

	before_save :uniq_arrays

	def validate_age_groups
		if !age_groups.is_a?(Array) || age_groups.detect{|a| !AGE_GROUPS.include?(a)}
			errors.add(:age_groups, :invalid)
		end
	end

	def validate_themes
		if !themes.is_a?(Array) || themes.detect{|t| !THEMES.include?(t)}
			errors.add(:themes, :invalid)
		end
	end

	def uniq_arrays
		self.age_groups.uniq!
		self.themes.uniq!
	end
end
