module PrintReport

  ##
  # function used to create the complete report as an .odt file
  def print_report(report_name, func, id=nil)

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
    when "umschlagkarte"
      template_name = "umschlagkarte"
    end
      
    ##
    # open template
    report = ODFReport::Report.new("#{Rails.root}/app/reports/" + template_name + ".odt") do |rep|

      ##
      # substitute placeholders in template
      if id.nil?
        func.call(rep)
      else
        func.call(rep, id)
      end
    end

    ##
    # generate .odt file with name provided by parameter report_name
    send_data report.generate, type: 'application/vnd.oasis.opendocument.text',
    disposition: 'attachment', filename: report_name + '.odt'

  end

  ##
  # the following functions are used to substitute the placeholders for a each report
  #NOTE: if you want to edit the label in the template, you have to delete and write it again, otherwise won't work


  def projekt(report)
    report.add_field(:title, 'Aktuelle Projekte')
    
    report.add_table("TABLE_1", Gprod.joins("INNER JOIN buecher ON buecher.gprod_id = gprods.id")
              .joins("INNER JOIN status_binderei ON status_binderei.gprod_id = gprods.id")
              .joins("INNER JOIN status_druck ON status_druck.gprod_id = gprods.id")
              .joins("INNER JOIN status_final ON status_final.gprod_id = gprods.id")
              .joins("INNER JOIN status_preps ON status_preps.gprod_id = gprods.id")
              .joins("INNER JOIN status_titelei ON status_titelei.gprod_id = gprods.id")
              .joins("INNER JOIN status_umschl ON status_umschl.gprod_id = gprods.id")
              .select("id","name", "isbn", "final_deadline", "projektname", "auflage", "binderei_bemerkungen", "bilder", "prio", "manusskript_eingang_date",
              "lektor_id", "seiten", "format_bezeichnung", "umschlag_bezeichnung", "titelei_bemerkungen", "satzproduktion", "papier_bezeichnung",
              "status_binderei.status AS status_bin", "status_druck.status AS status_dru", "status_final.status AS status_fin",
              "status_preps.status AS status_pre","status_titelei.status AS status_tit","status_umschl.status AS status_ums"),
              :header=>true) do |t|
                
      t.add_column(:id, :id)
      t.add_column(:pname, :projektname)
      t.add_column(:name, :name)
      t.add_column(:isbn, :isbn)
      t.add_column(:auflage, :auflage)
      t.add_column(:sollf, :final_deadline)
      t.add_column(:bi, :binderei_bemerkungen)
      t.add_column(:druck, :bilder)
      t.add_column(:prio, :prio)
      t.add_column(:msein, :manusskript_eingang_date)
      t.add_column(:lek, :lektor_id)
      t.add_column(:seiten, :seiten)
      t.add_column(:format, :format_bezeichnung)
      t.add_column(:umschlag, :umschlag_bezeichnung)
      t.add_column(:titelei, :titelei_bemerkungen)
      t.add_column(:satz, :satzproduktion)
      t.add_column(:papier, :papier_bezeichnung)
      t.add_column(:s_binderei, :status_bin)
      t.add_column(:s_druck, :status_dru)
      t.add_column(:s_final, :status_fin)
      t.add_column(:s_preps, :status_pre)
      t.add_column(:s_titelei, :status_tit)
      t.add_column(:s_umschlag, :status_ums) 
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

  # The used template is a dummy file, but the design, that is passing the
  # gprod id to this function via a batch_action, seems reasonable. Like this
  # we can even print a selection of 'Umschlagkarten'.
  def umschlagkarte(report, id)
    report.add_field(:title, 'Umschlagkarte')
    gprod = Gprod.where(id: id).first
    raise Exception, "Cannot happen, cuz we get the id from a gprod." if gprod.nil?
    begin
      report.add_field(:autor, gprod.autor.name)
      report.add_field(:titel, gprod.buch.titel1)
      report.add_field(:pages, gprod.buch.seiten)
      report.add_field(:rm, gprod.buch.rueckenstaerke)
      report.add_field(:sollf, gprod.final_deadline)
      report.add_field(:format, gprod.buch.format_bezeichnung)
    rescue NoMethodError
      Rails.logger.fatal "Failed to create the 'Umschlagkarte'"
    end
  end

end
