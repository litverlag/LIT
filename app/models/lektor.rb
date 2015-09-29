class Lektor < ActiveRecord::Base
  has_many :admin_users_lektoren
  has_many :admin_users, through: :admin_users_lektoren
  accepts_nested_attributes_for :admin_users, :allow_destroy => true
  accepts_nested_attributes_for :admin_users_lektoren, :allow_destroy => true
 end
