##
# #/app/models/admin_user.rb
#
# This model represents the Users of the system. For the management of the log in we have used devise and for the right we have used cancancan

class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable


  belongs_to :lektor
  accepts_nested_attributes_for :lektor

  has_and_belongs_to_many :departments
  accepts_nested_attributes_for :departments

end