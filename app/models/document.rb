class Document < ActiveRecord::Base
  belongs_to :user
  has_many :approvals
  has_many :reviews

  has_many :users, through: :approvals
  has_many :users, through: :reviews
end
