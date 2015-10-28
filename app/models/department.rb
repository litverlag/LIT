class Department < ActiveRecord::Base

	has_and_belongs_to_many :admin_users
	accepts_nested_attributes_for :admin_users, :allow_destroy => true	



end
