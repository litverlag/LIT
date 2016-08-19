require 'test_helper'

class BuchTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
	test "book existence" do
		assert_not_nil Buch.where(isbn: '3-123-33214-6').first
	end
end
