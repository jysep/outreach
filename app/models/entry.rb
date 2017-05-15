class Entry < ApplicationRecord
	OUTCOMES = {
		"1" => "Not Home",
		"2" => "Not Visited",
		"3" => "No Answer",
		"4" => "Not Interested",
		"6" => "No Children/Youth",
		"7" => "Visited",
		"8" => "Revisit",
		"5" => "Interested"
	}
	AGE_GROUPS = {
		"1" => "Children",
		"2" => "Junior Youth",
		"3" => "Youth"
	}
	THEMES = {
			"1" => "Walking a Path of Service",
			"2" => "Period of Youth",
			"3" => "Twofold Moral Purpose",
			"4" => "Constructive and Destructive Forces",
			"5" => "Material and Spiritual Progress",
			"6" => "Individual and Collective Transformation",
			"7" => "A United Community",
			"8" => "Community Building",
			"9" => "Service to the Community",
			"10" => "Early Adolescence",
			"11" => "Educating Younger Generations",
			"12" => "Institute Process",
			"13" => "The Baha'i Faith"
	}

	belongs_to :campaign
	has_many :duplicates, foreign_key: :entry1_id, dependent: :destroy
	has_many :more_duplicates, class_name: "Duplicate", foreign_key: :entry2_id, dependent: :destroy
	validates :team, presence: true
	validates :date, presence: true
	validates :street, presence: true
	validates :street_number, presence: true
	validates :outcome, presence: true, inclusion: { in: OUTCOMES.keys }
	validate :validate_age_groups
	validate :validate_themes

	before_save :uniq_arrays

	def validate_age_groups
		if !age_groups.is_a?(Array) || age_groups.detect{|a| !AGE_GROUPS.keys.include?(a)}
			errors.add(:age_groups, :invalid)
		end
	end

	def validate_themes
		if !themes.is_a?(Array) || themes.detect{|t| !THEMES.keys.include?(t)}
			errors.add(:themes, :invalid)
		end
	end

	def uniq_arrays
		self.age_groups.uniq!
		self.themes.uniq!
	end

	def full_address
		"#{street_number} #{street}" + (unit_number.blank? ? "" : " ##{unit_number}")
	end
end
