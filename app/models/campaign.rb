class Campaign < ApplicationRecord
	before_create { self.id = SecureRandom.base58(24) }

	has_many :permissions, dependent: :destroy
end
