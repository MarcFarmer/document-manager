class Question < ActiveRecord::Base
	belongs_to :training

	has_many :answers
end