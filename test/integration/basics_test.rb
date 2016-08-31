require 'test_helper'

class BasicsTest < ActionDispatch::IntegrationTest

	test "watch some pages" do
		get "/admin/projekte"
		assert_response :redirect
		get "/admin/login"
		assert_select "title", "Login | Produktions Tabellen"
	end

	test "login as mister bellmann" do
		post "/admin/login", params: { 
			admin_user: { email: 'bellmann@lit-verlag.de', password: 'ilikewine'},
			commit: 'Login'
			}
		assert_response :success
		get "/"
		assert_response :redirect
		assert_select 'form', false, 'This page must contain no forms.'
		get "/admin/projekte"
		# .. hm why .. 
		#assert_select 'h1', 'Produktions Tabellen'
	end

end
