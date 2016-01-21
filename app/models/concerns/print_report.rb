module PrintReport

	def print_projekt

    report = ODFReport::Report.new("#{Rails.root}/app/reports/test_projekt.odt") do |r|

    	r.add_field(:title, 'Hello World')
    	r.add_field(:user, current_admin_user.id)
      r.add_field(:date, Time.now)

    end

    send_data report.generate, type: 'application/vnd.oasis.opendocument.text', disposition: 'attachment', filename: 'report1.odt'
  end


end