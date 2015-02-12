class Document < ActiveRecord::Base
  has_many :approvals
  has_many :reviews

  has_many :users, through: :approvals
  has_many :users, through: :reviews
end
