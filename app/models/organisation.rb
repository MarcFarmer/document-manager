class Organisation < ActiveRecord::Base
  has_many :documents
  has_many :document_types

  has_many :users, through :organisation_users
end
