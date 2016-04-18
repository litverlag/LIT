module PrintReport

	##
	# function used to create the complete report as an .odt file
	def print_report(report_name, func)

		##
		# evaluate name of template using name of method given as parameter func
		case func.name.to_s
		when "projekt"
			template_name = "report_projekt"
		when "titelei"
			template_name = "report_titelei"
		when "umschlag"
			template_name = "report_umschlag"
		when "preps"
			template_name = "report_preps"
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
	#NOTE: if you want to edit the label in the template, you have to delete and write it again, otherwise won't work


	def projekt(report)
		report.add_field(:title, 'Aktuelle Projekte')

		report.add_table("TABLE_1", Gprod.joins("INNER JOIN buecher ON buecher.gprod_id = gprods.id")
		          .select("id","name", "isbn", "final_deadline", "projektname", "auflage", "binderei_bemerkungen", "prio", "manusskript_eingang_date",
		          "lektor_id", "seiten", "format_bezeichnung", "umschlag_bezeichnung", "titelei_bemerkungen", "papier_bezeichnung"),
		          :header=>true) do |t|
			t.add_column(:id, :id)
			t.add_column(:pname, :projektname)
			t.add_column(:name, :name)
      t.add_column(:isbn, :isbn)
      t.add_column(:auflage, :auflage)
      t.add_column(:sollf, :final_deadline)
      t.add_column(:bi, :binderei_bemerkungen)
      t.add_column(:druck, "bac")
      t.add_column(:prio, :prio)
      t.add_column(:msein, :manusskript_eingang_date)
      t.add_column(:lek, :lektor_id)
			t.add_column(:seiten, :seiten)
			t.add_column(:format, :format_bezeichnung)
			t.add_column(:umschlag, :umschlag_bezeichnung)
      t.add_column(:titelei, :titelei_bemerkungen)
			t.add_column(:papier, :papier_bezeichnung)
			#TODO: which attributes must be shown on this print?? 
		end

  	report.add_field(:user, current_admin_user.email)
    report.add_field(:date, Time.now)
	end

	def titelei(report)
		report.add_field(:title, 'Aktuelle Titelei-Aufträge')

		report.add_table("TABLE_1",
			Gprod.joins("INNER JOIN status_titelei ON status_titelei.gprod_id = gprods.id").select(:status, :projektname),
			:header=>true) do |t|

			t.add_column(:status, :status)
			t.add_column(:name, :projektname)
			#TODO: which attributes must be shown on this print?? 
		end

  	report.add_field(:user, current_admin_user.email)
    report.add_field(:date, Time.now)
	end

	def umschlag(report)
		report.add_field(:title, 'Aktuelle Umschlag-Aufträge')

		report.add_table("TABLE_1",
			Gprod.joins("INNER JOIN status_umschl ON status_umschl.gprod_id = gprods.id").select(:status, :projektname),
			:header=>true) do |t|

			t.add_column(:status, :status)
			t.add_column(:name, :projektname)
			#TODO: which attributes must be shown on this print?? 
		end

  	report.add_field(:user, current_admin_user.email)
    report.add_field(:date, Time.now)
	end

	def preps(report)
		report.add_field(:title, 'Aktuelle Preps-Aufträge')

		report.add_table("TABLE_1",
			Gprod.joins("INNER JOIN status_preps ON status_preps.gprod_id = gprods.id").select(:status, :projektname),
			:header=>true) do |t|

			t.add_column(:status, :status)
			t.add_column(:name, :projektname)
			#TODO: which attributes must be shown on this print?? 
		end

  	report.add_field(:user, current_admin_user.email)
    report.add_field(:date, Time.now)
	end



end