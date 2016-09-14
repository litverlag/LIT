require 'test_helper'

class AutorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
	test "existance" do
		assert_not_nil Autor.where(email: 'longbook@gmx.de').first
		assert_not_nil Autor.where(email: 'pmschilling@t-online.de').first
		assert_not_nil Autor.where(email: 'puza@uni-tuebingen.de').first
	end
end
