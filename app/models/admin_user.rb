class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable


  has_one :lektor
  accepts_nested_attributes_for :lektor

  has_and_belongs_to_many :departments
  accepts_nested_attributes_for :departments

end