require 'test_helper'

class BuchTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
	test "book existence" do
		assert_not_nil Buch.where(isbn: '3-123-33214-6').first
	end

	test "linking buch_reihe" do
		buch_id = 980190962
		reihe_id = 109283
		buch = Buch.where(id: buch_id).first
		reihe = Reihe.where(id: reihe_id).first

		id = buch.reihe_ids
		if id != []
			assert_includes id, reihe['id']
		else
			buch.reihe_ids= reihe['id']
			assert_includes buch.reihe_ids, reihe['id']
			assert_includes reihe.buch_ids, buch['id']
		end
	end
end
