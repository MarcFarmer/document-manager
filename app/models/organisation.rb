class Organisation < ActiveRecord::Base
  belongs_to :user

  has_many :documents
  has_many :document_types

  has_many :organisation_users
  has_many :users, through: :organisation_users
end
