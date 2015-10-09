class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable

  has_many :admin_users_lektoren
  has_many :lektoren, through: :admin_users_lektoren
  accepts_nested_attributes_for :lektoren, :allow_destroy => true
  accepts_nested_attributes_for :admin_users_lektoren, :allow_destroy => true

  has_many :admin_users_departments
  has_many :departments, through: :admin_users_departments#, source: :admin_user
  accepts_nested_attributes_for :departments, :allow_destroy => true
  accepts_nested_attributes_for :admin_users_departments, :allow_destroy => true

end