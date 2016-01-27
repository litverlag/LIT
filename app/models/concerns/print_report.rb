module PrintReport

	##
	# function used to create the complete report as an .odt file
	def print_report(report_name, func)

		##
		# evaluate name of template using name of method given as parameter func
		case func.name.to_s
		when "projekt"
			template_name = "report_projekt"
		end
			
		##
		# open template
		report = ODFReport::Report.new("#{Rails.root}/app/reports/" + template_name + ".odt") do |rep|

			##
			# substitute placeholders in template
			func.call(rep)
		end

		##
		# generate .odt file with name provided by parameter report_name
		send_data report.generate, type: 'application/vnd.oasis.opendocument.text',
		disposition: 'attachment', filename: report_name

	end

	##
	# the following functions are used to substitute the placeholders for a each report
	def projekt(report)
		report.add_field(:title, 'Hello World')

		report.add_table("TABLE_1", Projekt.select("id", "projektname"), :header=>true) do |t|
			t.add_column(:id, :id)
			t.add_column(:name, :projektname)
		end

  	report.add_field(:user, current_admin_user.id)
    report.add_field(:date, Time.now)
	end



end