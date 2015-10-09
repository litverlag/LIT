class Department < ActiveRecord::Base


  has_many :admin_users_deparments
  has_many :admin_users, through: :admin_users_departments#, source: :department
  accepts_nested_attributes_for :admin_users, :allow_destroy => true
  accepts_nested_attributes_for :admin_users_deparments, :allow_destroy => true



end
