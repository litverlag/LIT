require 'test_helper'

class BuchTest < ActiveSupport::TestCase
	test "book existence" do
		assert_not_nil Buch.where(isbn: '3-123-33214-6').first
		assert_not_nil Buch.where(isbn: '978-3-643-90794-3').first
		assert_not_nil Buch.where(isbn: '978-3-643-12298-8').first
		assert_not_nil Buch.where(isbn: '3-643-12530-0').first
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

	test "backsize function" do
		b = Buch.where(isbn: '3-123-33214-6').first
		assert_equal 20, b.backsize
		b = Buch.where(isbn: '978-3-643-90794-3').first
		assert_equal 7, b.backsize
	end
end
