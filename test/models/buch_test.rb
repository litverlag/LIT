require 'test_helper'

class BuchTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
	test "google script 80221-7" do
		testbuch = Buch.where(isbn: '80221-7').first
		unless testbuch.nil?
			assert_equal( testbuch[:name], 'Hesse' )
			assert_equal( testbuch[:seiten], 100   )
		else
			assert false
		end
	end
end
