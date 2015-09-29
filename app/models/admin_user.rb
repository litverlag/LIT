class AdminUser < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :trackable, :validatable

  has_many :admin_users_lektoren
  has_many :lektoren, through: :admin_users_lektoren
  accepts_nested_attributes_for :lektoren, :allow_destroy => true
  accepts_nested_attributes_for :admin_users_lektoren, :allow_destroy => true
end