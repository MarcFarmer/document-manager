class Review < ActiveRecord::Base
  belongs_to :document
  belongs_to :user
end
