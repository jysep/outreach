class Visit < ApplicationRecord
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

	belongs_to :entry

	validates :team, presence: true
	validates :date, presence: true
	validates :outcome, presence: true, inclusion: { in: OUTCOMES.keys }
	validate :validate_themes

	before_save :uniq_arrays

	def validate_themes
		if !themes.is_a?(Array) || themes.detect{|t| !THEMES.keys.include?(t)}
			errors.add(:themes, :invalid)
		end
	end

	def outcome_text
		OUTCOMES[outcome]
	end

	def uniq_arrays
		self.themes.uniq!
	end
end
