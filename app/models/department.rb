##
# # /app/models/departement.rb
#
# Represents the Department of each user. Belongs to a table with all departments.Is only used
# for the CRUD right with cancancan see ability.rb
class Department < ActiveRecord::Base

	has_and_belongs_to_many :admin_users
	accepts_nested_attributes_for :admin_users
	has_one :department_show_setting
	has_one :department_input_setting

end
