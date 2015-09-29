class AdminUsersLektor < ActiveRecord::Base
	belongs_to :admin_user
	belongs_to :lektor
end
