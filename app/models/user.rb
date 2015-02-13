class User < ActiveRecord::Base
  has_many :approvals
  has_many :reviews
  has_many :documents

  has_many :documents, through: :approvals
  has_many :documents, through: :reviews
  has_many :organisations, through: :organisation_users

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
