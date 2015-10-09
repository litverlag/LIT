class AdminUsersDepartment < ActiveRecord::Base

  belongs_to :department
  belongs_to :admin_user

end
