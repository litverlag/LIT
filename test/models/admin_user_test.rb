require 'test_helper'

class AdminUserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
	test "admin user passwords" do
		a = AdminUser.where(vorname: 'Richter').first
		assert_not_nil a
		unless a.nil?
			puts "vorname: #{a.vorname}, pw: #{a.encrypted_password}"
		end
		b = AdminUser.create!(vorname: 'widl', password: 'password', email: 'some@one.lonely')
		unless b.nil?
			puts "vorname: #{b.vorname}, password == #{b.encrypted_password}"
		end
	end
end
