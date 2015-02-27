class Document < ActiveRecord::Base
  belongs_to :user
  belongs_to :organisation
  has_many :approvals
  has_many :reviews
  has_many :readers
  belongs_to :document_type

  has_many :document_revisions
  accepts_nested_attributes_for :document_revisions

  # paperclip gem
  has_attached_file :doc
  do_not_validate_attachment_file_type :doc     # TODO choose valid file types

  has_many :users, through: :approvals
  has_many :users, through: :readers
  has_many :users, through: :reviews

  validates :title, presence: true, length: { maximum: 255 }
  validates :status, presence: true
  validate :content_xor_doc

  #tags

  has_many :organisation_tags
  has_many :document_tags , :through => :organisation_tags





  private

  def content_xor_doc
    if !(content.blank? ^ doc.blank?)
      errors.add(:base, "Add editor content or an uploaded document, not both")
    end
  end
end
