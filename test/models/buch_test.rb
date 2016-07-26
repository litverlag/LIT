require 'test_helper'

class BuchTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
	testbuch = Buch.where(isbn: '80221-7')
	assert_equal( testbuch.name, 'Hesse' )
	assert_equal( testbuch.seiten, 100   )
end
