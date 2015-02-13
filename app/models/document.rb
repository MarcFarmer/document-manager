class Document < ActiveRecord::Base
  belongs_to :user
  belongs_to :organisation
  has_many :approvals
  has_many :reviews
  belongs_to :document_type

  has_many :users, through: :approvals
  has_many :users, through: :reviews
end
