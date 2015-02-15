class Document < ActiveRecord::Base
  belongs_to :user
  belongs_to :organisation
  has_many :approvals
  has_many :reviews
  belongs_to :document_type

  # paperclip gem
  has_attached_file :doc
  do_not_validate_attachment_file_type :doc     # TODO choose valid file types

  has_many :users, through: :approvals
  has_many :users, through: :reviews
end
