class DocumentType < ActiveRecord::Base
  belongs_to :organisation
  has_one :document
end
