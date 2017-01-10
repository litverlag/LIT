require 'test_helper'

class DepartmentInputSettingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

	##
	# Damit. sqlite3 has no array data type so.. either we switch the test
	# environment to a posgresql database.. or .. we dont make functional tests
	# for this class.
	##

#	test "saving and loading" do
#		d = DepartmentInputSetting.all.first
#		d.gprods_options = [true, false, true, false, true, false]
#		d.save!
#		DepartmentInputSetting.save_persistent 'widl'
#		d.gprods_options = [false, true, false, true, false, true]
#		d.save!
#		DepartmentInputSetting.load_persistent 'widl'
#		assert d.gprods_options == [true, false, true, false, true, false]
#		`rm config/widl.yml`
#	end
end
