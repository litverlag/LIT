require 'test_helper'

# TODO More test cases would be convenient.
class GapiTest < ActiveSupport::TestCase
	test "raking something" do
		session = GoogleDrive.saved_session(".credentials/client_secret.json")
		spreadsheet = session.spreadsheet_by_key("1YWWcaEzdkBLidiXkO-_3fWtne2kMgXuEnw6vcICboRc")
		#$SPREADSHEET = "1YWWcaEzdkBLidiXkO-_3fWtne2kMgXuEnw6vcICboRc" 
		#...

		logger = Logger.new($stdout)
		$TABLE = 'Unittests'
		table = spreadsheet.worksheet_by_title('Unittests')
		rake_umschlag_table(table, logger)

		buch = Buch.where(isbn: '978-3-643-90794-3').first
		assert_equal 112, buch['seiten']
		assert_not_nil buch.gprod
		assert_equal buch['papier_bezeichnung'], I18n.t('paper_names.offset80')
	end
end

#load '../../lib/tasks/import_prod.rake'
#class GapiBTest < ActionDispatch::IntegrationTest
