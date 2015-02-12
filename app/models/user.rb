class User < ActiveRecord::Base
  has_many :approvals
  has_many :reviews

  has_many :documents, through: :approvals
  has_many :documents, through: :reviews

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
end
