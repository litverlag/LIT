require 'test_helper'

class BasicsTest < ActionDispatch::IntegrationTest
	fixtures :all
	#include ActiveAdmin::Devise::Controllers::SignInOut

	test "watch some pages" do
		get "/admin/projekte"
		assert_response :redirect
		get "/admin/login"
		assert_select "title", "Login | Produktions Tabellen"
	end

	test "lektor login existace" do
		assert_not_nil AdminUser.where(vorname: 'Bellissimo').first
	end

	test "login as mister bellmann" do

		post "/admin/login", params: { 
			admin_user: { email: admin_users(:bellmann).email, password: admin_users(:bellmann).password },
			commit: 'Login'
			}
		assert_response :success
		puts /(.*?flash.*)/.match(@response.body)[1]
		#puts @response.body

		get "/admin/projekte/3333"
		assert_response :redirect
		follow_redirect!
		#puts @response.body
	end

end
