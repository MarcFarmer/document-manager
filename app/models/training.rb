class Training < ActiveRecord::Base
	belongs_to :organisation
	belongs_to :document

	has_many :users
	has_many :questions
end
