# As reader you may wonder why the author didn't write at least one class for
# this task.
namespace :gapi do
  require 'logger'
  require 'date'

	# If projekt's sollf is more in the past than this amount of days, then its
	# final_status will be set to 'fertig', cause we clearly missed that
	# information.
	$DAYS_SET_PJ_DONE = 60

  # Map the header of each column to the column number.
  def get_col_from_title( table )
    index = ( 1..table.max_cols ).drop(0)
    name = table.rows[0]
    return Hash[*name.zip(index).flatten]
  end


  # Now some functions parsing a single entrys in the 'produktionstabelle'.

  def check_papier_entry( entry , logger=nil )
    tok = nil
    if    entry =~ /o? ?80|80 ?o/i;       tok = I18n.t('paper_names.offset80')
    elsif entry =~ /o ?90|90 ?o/i;        tok = I18n.t('paper_names.offset90')
    elsif entry =~ /(wg ?90)|(90 ?wg)/i;  tok = I18n.t('paper_names.werk90g')
    elsif entry =~ /(w ?90)|(90 ?w)/i;    tok = I18n.t('paper_names.werk90b')
    elsif entry =~ /wg? ?100|100 ?wg?/i;  tok = I18n.t('paper_names.werk100')
    else
      logger.error "Unknown 'papier_bezeichnung': '#{entry}'" unless logger.nil?
    end
    return tok
  end

  def check_bindung_entry( entry , logger=nil )
    tok = nil
    extern = nil
    if    entry =~ /\+/i ;    tok = 'multi: ' + entry     ; extern = true
    elsif entry =~ /fhc/i;    tok = I18n.t('bi_names.fhc'); extern = true
    elsif entry =~ /k/i  ;    tok = I18n.t('bi_names.k')  ; extern = false
    elsif entry =~ /f/i  ;    tok = I18n.t('bi_names.f')  ; extern = true
    elsif entry =~ /h/i  ;    tok = I18n.t('bi_names.h')  ; extern = true
    else
      logger.error "Unknown 'bindung': '#{entry}'" unless logger.nil?
    end
    return tok, extern
  end

  def check_um_abteil_entry( entry, logger=nil )
    tok = nil
    if    entry =~ /te?x/i;   tok = I18n.t('um_names.tex')
    elsif entry =~ /in/i;     tok = I18n.t('um_names.indesign')
    elsif entry =~ /neu/i;    tok = I18n.t('um_names.unknown')
    elsif entry =~ /autor/i;  tok = I18n.t('um_names.extern')
    else
      logger.error "Unknown 'umschlag abteilung': '#{entry}'" unless logger.nil?
    end
    return tok
  end

  def check_umformat_entry( entry, logger=nil )
    tok = nil
    if    entry =~ /a3/i;     tok = I18n.t('format_names.a3')
    elsif entry =~ /a4/i;     tok = I18n.t('format_names.a4')
    elsif entry =~ /a5|21/i;  tok = I18n.t('format_names.a5')
    elsif entry =~ /a6/i;     tok = I18n.t('format_names.a6')
    elsif entry =~ /24/i;     tok = I18n.t('format_names.sonder24')
    elsif entry =~ /23/i;     tok = I18n.t('format_names.sonder23')
    elsif entry =~ /22/i;     tok = I18n.t('format_names.sonder22')
    elsif entry =~ /sonder/i; tok = entry
    else
      logger.error "Unknown 'Buchformat': '#{entry}'" unless logger.nil?
    end
    return tok
  end

  def check_prio_entry( entry, logger=nil )
    tok = nil
    sonder = ''

    if    entry =~ /z/i; tok = 'Z'
    elsif entry =~ /a/i; tok = /(a+)/i.match(entry)[1].upcase
    elsif entry =~ /b/i; tok = 'B'
    elsif entry =~ /c/i; tok = 'C'
    else
      logger.error "Unknown 'Prio/Sonder': '#{entry}'" unless logger.nil?
    end

    unless (tmp = /(pf).*?(\d+)/i.match(entry)).nil?
      sonder += "Pflichtexemplare: #{tmp[2]}\n" unless tmp[2].nil?
    end
    unless (tmp = /(sonder).*?(\d+)/i.match(entry)).nil?
      sonder += "Sonderexemplare: #{tmp[2]}\n" unless tmp[2].nil?
    end
    unless (tmp = /(vorab).*?(\d+)/i.match(entry)).nil?
      sonder += "Vorabexemplare: #{tmp[2]}\n" unless tmp[2].nil?
    end
    unless (tmp = /(fr).*?(\d+)/i.match(entry)).nil?
      sonder += "Freiexemplare: #{tmp[2]}\n" unless tmp[2].nil?
    end

    if    entry =~ /m/i;      sonder += 'Monographie'
    elsif entry =~ /sb/i;     sonder += 'Sammelband mit Beiträgerversand'
    elsif entry =~ /s/i;      sonder += 'Sammelband'
    end
    sonder = nil if sonder.empty?
    return tok, sonder
  end

  def check_druck_entry( entry, logger=nil )
    return [nil,nil,nil] if entry.empty?
    ext = nil
    tok = nil
    bild = nil
    if    entry =~ /^\s*x\s*$/i;    tok = 'Digitaldruck'  end
    if    entry =~ /x1/i;           bild = 'x1'
    elsif entry =~ /x2/i;           bild = 'x2'
    elsif entry =~ /x3/i;           bild = 'x3'
    elsif entry =~ /x3/i;           bild = 'x3'
    end
    if    entry =~ /ex/i;           ext = true            end
    if ext.nil? and tok.nil? and bild.nil?
      logger.error "Unknown 'druck': '#{entry}'" unless logger.nil?
    end
    return ext, tok, bild
  end

  def check_korrektorat_entry( entry, logger=nil )
    tok = nil
    if    entry =~ /0/i;      tok = 'Fertig'
    elsif entry =~ /satz/i;   tok = nil
    elsif entry =~ /ok/i;     tok = nil
    else
      logger.error "Unknown 'korrektorat': '#{entry}'" unless logger.nil?
    end
    return tok
  end

  # Could have made those regexpressions less verbose..
  def check_auflage_entry( entry, logger=nil )
    return entry, nil if entry.class == Fixnum
    match = /\s*?(\d+)\s*?\((\d+)\)/.match(entry)
    unless match.nil?
      auflage = match[1].to_i
      abnahme = match[2].to_i
    else
      match = /\s*\((\d+)\)\s*/.match(entry)
      if match.nil?
        match = /.*?(\d+)/.match(entry)
        auflage = match[1].to_i unless match.nil?
      else
        abnahme = match[1].to_i unless match.nil?
      end
    end
    if auflage.nil? and abnahme.nil?
      logger.error "Unknown 'auflage': '#{entry}'" unless logger.nil?
    end
    return auflage, abnahme
  end

  def check_date_entry( entry, logger=nil )
    return nil if entry =~ /autor/i or entry.empty?
    begin
      date = Date.parse(entry) 
    rescue
      logger.debug "Invalid date: '#{entry}'" unless logger.nil?
    end
    return date
  end

  def check_email_entry( entry, logger=nil )
    m = /.*?([\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+).*?/i.match(entry)
    if m.nil? or m[1].nil?
      logger.error "Unknown 'email': '#{entry}'" unless logger.nil?
      return nil
    end
    return m[1]
  end

	## Satz status must follow those rules:
	# '0_F'  =>  Datei zum Satz Freigegeben
	# '0_K'  =>  Konvertiert, in Bearbeitung
	# 'n_F'  =>  n-te Fahne
	# 'n_FA' =>  n-te Fahne zurück
	# 'F_p'  =>  Druckfreigabe für Prepser
	# '0'    =>  siehe Kommentar
	def check_st_satz_entry(entry, logger=nil)
		tok = nil
		if    entry =~ /^\s*0.*f\s*$/i;				tok = nil #neu
		elsif entry =~ /^\s*0.*k\s*$/i;				tok = nil #bearbeitung
		elsif entry =~ /^\s*[1-9].*f\s*$/i;		tok = nil #verschickt
		elsif entry =~ /^\s*[1-9].*fa\s*$/i;	tok = nil #bearbeitung
		elsif entry =~ /^\s*f/i;							tok = nil #fertig
		elsif entry =~ /_p/i;									tok = nil #problem
		else
			logger.error "Unknown 'st_satz': '#{entry}'" unless logger.nil?
		end
		return tok
	end


  ## EMPTY PROTOTYPE, replace xxx with column name.
# def check_xxx_entry( entry, logger=nil )
#   tok = nil
#   if    entry =~ //i;   tok = nil
#   elsif entry =~ //i;   tok = nil
#   else
#     logger.error "Unknown 'xxx': '#{entry}'" unless logger.nil?
#   end
#   return tok
# end

  def find_buch_by_shortisbn(short_isbn, logger)
    if short_isbn.nil? or short_isbn.empty?
      logger.fatal "ISBN: empty? '#{short_isbn}'"
      return nil
    end

    short_isbn.rstrip!
    short_isbn.lstrip!
    buch = Buch.where("isbn like '%#{short_isbn}'").first
    if buch.nil?
      m = /([0-9]+-[0-9]+)$/i.match(short_isbn)
      buch = Buch.where("isbn like '%#{m[1]}'").first unless m.nil?
    end
    if buch.nil?
      if (/[0-9]{5}-[0-9]/ =~ short_isbn) == 0
        logger.fatal "ISBN -- not found: '#{short_isbn}'"
      elsif (/[0-9]{3}-[0-9]/ =~ short_isbn) == 0
        buch = find_buch_by_ate(short_isbn, logger)
        logger.fatal "ISBN -- ATE/EGL not found: '#{short_isbn}'" if buch.nil?
      else
        logger.fatal "ISBN -- unknown format: '#{short_isbn}'"
      end
    end
    return buch
  end

  def find_buch_by_ate(isbn, logger)
    m = /.*(\d+-\d+-\d)[!\d]/.match(isbn)
    isbn = m[1] unless m.nil?
    return Buch.where( "isbn like '%#{isbn}'" ).first
  end

  ##
  # Note that you must initialize COLOR_D, which is usually done with the
  # " ./lib/tasks/gapi_get_color_vals.rb " script.
  #
  # Note also that no error is generated if you dont initialize this global
  # variable.
  def color_from(row, dict, rowname, abteil, status, table, logger)
    color = $COLOR_D[ $COLORS[row-1][dict[rowname]-1]] rescue nil

    if color.nil? or table[color.to_s].nil?
      # Log error, and status = default status (that is 'fertig')
      logger.error "Color: '#{rowname}' column: #{row}" unless dict[rowname].nil?
      if status.nil?
        status = abteil.create!(status: I18n.t("scopes_names.neu_filter"))
      else
        status['status'] = I18n.t("scopes_names.fertig_filter")
      end

    elsif status.nil?
      status = abteil.create!(status: table[color])

    else
      status['status'] = table[color]
    end

    return status
  end

  def rake_umschlag_table( table, logger )
    h = get_col_from_title( table )

    $COLORS = nil
    $COLOR_D = nil
    load 'lib/tasks/gapi_get_color_vals.rb'
    if $COLORS.nil? or $COLOR_D.nil?
      puts "Fatal error, could not get Color values from the ./gapi_get_color_vals.rb script."
      puts "Exiting, this makes no sense without status information."
      exit
    end

    general_color_table = {
      'white'       => I18n.t("scopes_names.neu_filter"),
      'yellow'      => I18n.t('scopes_names.verschickt_filter'),
      'brown'       => I18n.t('scopes_names.bearbeitung_filter'),
      'green'       => I18n.t('scopes_names.fertig_filter'),
      'dark green'  => I18n.t('scopes_names.fertig_filter'),
      'pink'        => I18n.t('scopes_names.problem_filter'), }
    umschlag_color_table = {
      'white'       => I18n.t("scopes_names.neu_filter"),
      'yellow'      => I18n.t('scopes_names.verschickt_filter'),
      'brown'       => I18n.t('scopes_names.bearbeitung_filter'),
      'green'       => I18n.t('scopes_names.fertig_filter'),
      'dark green'  => I18n.t('scopes_names.fertig_filter'),
      'turquois'    => I18n.t('scopes_names.problem_filter'), }
    lektorname = {
      'hf'      => 'Hopf',
      'whf'     => 'Hopf',
      'hfch'    => 'Hopf',
      'rai'     => 'Rainer',
      'rainer'  => 'Rainer',
      'rit'     => 'Richter',
      'bel'     => 'Bellman',
      'berlin'  => 'Lit Berlin',
      'litb'    => 'Lit Berlin',
      'wien'    => 'Lit Wien',
      'wla'     => 'Lit Wien',
      'opa'     => 'Unknown_opa',
      'ch'      => 'Unknown_ch',
      'web'     => 'Unknown_web' }
    lektoremailkuerzel = {
      'hf'  => 'hopf@lit-verlag.de',
      'whf' => 'hopf@lit-verlag.de',
      'hfch'=> 'hopf@lit-verlag.de',
      'rai' => 'rainer@lit-verlag.de',
      'rit' => 'richter@lit-verlag.de',
      'bel' => 'bellmann@lit-verlag.de',
      'litb'=> 'berlin@lit-verlag.de',
      'wla' => 'wien@lit-verlag.de',
      'wien'=> 'wien@lit-verlag.de',
      'ch'  => 'unknown_ch@invalid.com',
      'opa' => 'unknown_opa@invalid.com',
      'web' => 'unknown_web@invalid.com' }

    (2..table.num_rows).each do |i| #skip first line: headers
      begin
        gprod = Gprod.where(projektname: table[i,h['Name']]).first
        gprod = Gprod.new(:projektname => table[i,h['Name']]) if gprod.nil?
      rescue TypeError => e
        logger.fatal "Table entry not found [#{e}], Skipping.."
        next
      end

      ##
      # If we cannot find the ISBN of the book in the database, we bail out.
      buch = find_buch_by_shortisbn(table[i,h['ISBN']], logger) rescue nil
      next if buch.nil?

      # 'Reihen'-code
      r_code = table[i,h['Reihe']] rescue nil
      if r_code.nil? or r_code.empty?
        logger.debug "Kein reihenkuerzel gefunden, das feld ist leer."
      else
        buch[:r_code] = r_code.downcase
        reihe = Reihe.where(r_code: r_code.downcase).first
      end

      # Lektor ID   -->   Buch && Lektor !
      fox_name = table[ i, h['Lek'] ] rescue nil
      lektor = Lektor.where(fox_name: fox_name).first unless fox_name.nil?

      if lektor.nil?
        lektor = Lektor.where(name: lektorname[fox_name.downcase]).first
      end
      if lektor.nil?
        lektor = Lektor.where(emailkuerzel: 
                              lektoremailkuerzel[fox_name.downcase]).first
      end

      if lektor.nil?
        logger.info \
          "Strange: We needed to create a missing lektor: '#{fox_name}'"
        lektor = Lektor.create!(
          :fox_name     => fox_name.downcase,
          :name         => 'Unknown_'+fox_name.downcase,
          :emailkuerzel => lektoremailkuerzel[fox_name.downcase]
        )
      end
      buch[:lektor_id] = lektor[:id]
      gprod[:lektor_id] = lektor[:id]

      # Autor ID and Projekt E-Mail
      email = check_email_entry(table[i,h['email']]) rescue nil
      if email.nil? or email.empty?
        # This will log a fatal error below.
        email = lektor[:emailkuerzel]       
      end
      gprod[:projekt_email_adresse] = email
      unless email == lektor[:emailkuerzel] 
        autor = Autor.where(email: email).first
        autor = Autor.where("name like '%#{gprod['projektname']}%'").first if autor.nil?
        unless autor.nil?
          buch[:autor_id] = autor[:id]
          gprod[:autor_id] = autor[:id]
        else
          logger.error "Author not found, any ideas? [1]"
        end
      else
        # email from Table does not belong to author.
        logger.error "Author not found, any ideas? [2]"
      end

      seiten = /\s*(\d*)\s*W?\s*(\d*)/i.match(table[i,h['Seiten']]) rescue nil
      if seiten and not seiten[2].empty?
        buch['seiten'] = seiten[2].to_i
      elsif seiten
        buch['seiten'] = seiten[1].to_i
      else
        logger.error "Could not undertstand 'Seiten' entry: col[#{i}]"
      end

      # Check the final billing entry, which is called 'st'.
      st = table[i,h['st']] rescue nil
      if st == "V"
        gprod.buchistfertig = true
        status_name = I18n.t('scopes_names.fertig_filter')
      else
        status_name = I18n.t('scopes_names.bearbeitung_filter')
      end
      begin
        gprod.statusfinal.status = status_name
      rescue
        gprod.statusfinal = StatusFinal.new(
          status: status_name
        )
      end

      ##                                 ##
      ##                                 ##

      bindung, extern = check_bindung_entry( table[i,h['Bi']], logger ) rescue nil
      buch[:bindung_bezeichnung] = bindung unless bindung.nil?
      gprod[:externer_druck] = extern unless extern.nil?

      auflage, abnahme = check_auflage_entry( table[i,h['Auflage']], logger ) rescue nil
      gprod[:auflage] = auflage unless auflage.nil?
      gprod[:gesicherte_abnahme] = abnahme unless abnahme.nil?

      papier = check_papier_entry( table[i,h['Papier']], logger ) rescue nil
      buch[:papier_bezeichnung] = papier unless papier.nil?

      gprod[:lektor_bemerkungen_public] = table[i,h['Sonder']] rescue nil

      um_abteil = check_um_abteil_entry( table[i,h['Umschlag']], logger ) rescue nil
      buch[:umschlag_bezeichnung] = um_abteil unless um_abteil.nil?

      format = check_umformat_entry( table[i,h['Format']], logger ) rescue nil
      buch[:format_bezeichnung] = format unless format.nil?

      prio, sonder = check_prio_entry( table[i,h['Prio/Sond']], logger ) rescue nil
      gprod[:prio] = prio unless prio.nil?
      gprod[:lektor_bemerkungen_public] = sonder unless sonder.nil?

      extern, druck, bilder = check_druck_entry( table[i,h['Druck']], logger ) rescue nil
      gprod[:externer_druck] = extern unless extern.nil?
      gprod[:druck_art] = druck unless druck.nil?
      gprod[:bilder] = bilder unless bilder.nil?

      msein = check_date_entry( table[i,h['MsEin']], logger ) rescue nil
      gprod.manusskript_eingang_date = msein unless msein.nil?

      sollf = check_date_entry( table[i,h['SollF']], logger ) rescue nil
      gprod.final_deadline = sollf unless sollf.nil?

      ##                 ##
      # Color information #
      ##                 ##
      #

      gprod.statuspreps = color_from(i, h, 'Papier', StatusPreps,
                                     gprod.statuspreps, general_color_table,
                                     logger)
      gprod.statustitelei = color_from(i, h, 'Titelei', StatusTitelei,
                                       gprod.statustitelei,
                                       general_color_table, logger)

      format_color = $COLOR_D[ $COLORS[i-1][h['Format']-1]] rescue nil
      if ['green','brown','pink'].include? format_color
        buch[:klappentext] = true
      elsif ['dark green'].include? format_color
        buch[:klappentext] = false
      end
      case format_color
      when 'green', 'dark green'
        gprod.klappentextinfo = I18n.t('scopes_names.fertig_filter')
      when 'brown'
        gprod.klappentextinfo = I18n.t('scopes_names.bearbeitung_filter')
      when 'pink'
        gprod.klappentextinfo = I18n.t('scopes_names.verschickt_filter')
      when 'white', nil
        gprod.klappentextinfo = I18n.t('scopes_names.neu_filter')
      end

      gprod.statusumschl = color_from(i, h, 'Umschlag', StatusUmschl,
                                      gprod.statusumschl, umschlag_color_table,
                                      logger)

      name_color = $COLOR_D[ $COLORS[i-1][h['Name']-1]]
      if name_color.nil?
        logger.error "Color: 'Name' column: #{i-1}"
      else
        gprod[:satzproduktion] = true if name_color == 'light pink'
      end

      gprod.statussatz = color_from(i, h, 'Satz', StatusSatz, gprod.statussatz,
                                    general_color_table, logger)
      gprod.statusdruck = color_from(i, h, 'Druck', StatusDruck,
                                     gprod.statusdruck, general_color_table,
                                     logger)

			# All projekts with a final_deadline (that is sollf) older than
			# $DAYS_SET_PJ_DONE days MUST be 'fertig'.
      unless gprod.final_deadline.nil?
        if gprod.final_deadline.compare_with_coercion(Date.today - $DAYS_SET_PJ_DONE) == -1
          status = true
					status_name = I18n.t('scopes_names.fertig_filter')
        else
          status = false
        end

        unless gprod.statusfinal.nil?
          gprod.statusfinal['freigabe'] = status
          gprod.statusfinal['status'] = status_name
        else
          gprod.statusfinal = StatusFinal.create!(
						freigabe: status,
						status: status_name
					)
        end
      end

      ##
      # Save 'em, so they get a computed ID, which we need for linking.
      gprod.save!
      buch.save!

      gprod.buch = buch if gprod.buch.nil?
      buch.gprod = gprod if buch.gprod.nil?

      buch.reihe_ids= reihe['id'] unless reihe.nil?
      reihe.autor_ids= autor['id'] unless autor.nil? or reihe.nil?
      autor.buch_ids= buch['id'] unless autor.nil?

      reihe.save! unless reihe.nil?
      autor.save! unless autor.nil?
      gprod.save!
      buch.save!
      # Save 'em again.
      ##

      logger.fatal "Gprod without buch: #{gprod['id']}" if gprod.buch == nil

    end # end row iteration
  end # end rake_umschlag_table function

  def rake_bi_table(table)
    logger = Logger.new('log/development_rake.log')
    h = get_col_from_title(table)
    $COLORS = nil
    $COLOR_D = nil
    load 'lib/tasks/gapi_get_color_vals.rb'
    if $COLORS.nil? or $COLOR_D.nil?
      puts "Fatal error, could not get Color values from the"+
            "./gapi_get_color_vals.rb script."
      puts "Exiting, this makes no sense without status information."
      exit
    end
    general_color_table = {
      'white'       => I18n.t('scopes_names.neu_filter'),
      'yellow'      => I18n.t('scopes_names.verschickt_filter'),
      'brown'       => I18n.t('scopes_names.bearbeitung_filter'),
      'green'       => I18n.t('scopes_names.fertig_filter'),
      'pink'        => I18n.t('scopes_names.problem_filter'), }

    (2..table.num_rows).each do |i| #skip first line: headers

      buch = find_buch_by_shortisbn(table[i,h['ISBN']], logger) rescue nil
      next if buch.nil?
      gprod = buch.gprod
      if gprod.nil?
        logger.fatal "Buch without gprod -- isbn[#{buch['isbn']}]"
        next
      end
      if gprod.statusdruck.nil?
        gprod.statusdruck = StatusDruck.create!(
          status: I18n.t("scopes_names.fertig_filter")
        )
      else
        gprod.statusdruck['status'] = I18n.t("scopes_names.fertig_filter")
      end

      gprod.statusbinderei = color_from(i, h, 'Name', StatusBinderei,
                                        gprod.statusbinderei,
                                        general_color_table, logger)

      gprod.save!

    end
  end # end rake_bi_table

  ##
  # Rake task for the tit table.
  def rake_tit_table(table)
    logger = Logger.new('log/development_rake.log')
    h = get_col_from_title(table)
    (2..table.num_rows).each do |i| #skip first line: headers
      buch = find_buch_by_shortisbn(table[i,h['ISBN']], logger) rescue nil
      next if buch.nil?
      gprod = buch.gprod
      if gprod.nil?
        logger.fatal "Buch without gprod -- isbn[#{buch['isbn']}]"
        next
      end

      vers_date = check_date_entry(table[i,h['Versand']], logger) rescue nil
      gprod.titelei_versand_datum_fuer_ueberpr = vers_date unless vers_date.nil?

      korr_date = check_date_entry(table[i,h['Korrektur']], logger) rescue nil
      gprod.titelei_korrektur_date = korr_date unless korr_date.nil?

      frei_date = check_date_entry(table[i,h['Freigabe']], logger) rescue nil
      gprod.titelei_freigabe_date = frei_date unless frei_date.nil?

      gprod.titelei_bemerkungen = table[i,h['Bemerkungen II']] rescue nil

      gprod.save!
      buch.save!
    end
  end

  ##
  # Rake task for mr. ExternerDruck
  def rake_ext_druck_table(table)
    logger = Logger.new('log/development_rake.log')
    h = get_col_from_title(table)

    # Needed for color_from function.
    $COLORS = nil
    $COLOR_D = nil
    load 'lib/tasks/gapi_get_color_vals.rb'
    if $COLORS.nil? or $COLOR_D.nil?
      puts "Fatal error, could not get Color values from the ./gapi_get_color_vals.rb script."
      puts "Exiting, this makes no sense without status information."
      exit
    end

    (2..table.num_rows).each do |i| #skip first line: headers
      buch = find_buch_by_shortisbn(table[i,h['ISBN']], logger) rescue nil
      next if buch.nil?
      gprod = buch.gprod
      if gprod.nil?
        logger.fatal "Buch without gprod -- isbn[#{buch['isbn']}]"
        next
      end

      vers_date = check_date_entry(table[i,h['an Extern']], logger) rescue nil
      gprod.externer_druck_verschickt = vers_date unless vers_date.nil?

      korr_date = check_date_entry(table[i,h['fertig soll']], logger) rescue nil
      gprod.externer_druck_deadline = korr_date unless korr_date.nil?

      frei_date = check_date_entry(table[i,h['grün fertig']], logger) rescue nil
      gprod.externer_druck_finished = frei_date unless frei_date.nil?

      ##
      # Special color table returns nil if field is white
      extdruck_color_table = {
        'yellow'      => I18n.t('scopes_names.verschickt_filter'),
        'green'       => I18n.t('scopes_names.fertig_filter'),}
      stat = color_from(
        i, h, 'grün fertig', StatusExternerDruck, gprod.statusexternerdruck,
        extdruck_color_table, logger
      )

      if stat.status == I18n.t('scopes_names.fertig_filter')
        gprod.statusexternerdruck = stat
      else
        stat = color_from(
          i, h, 'an Extern', StatusExternerDruck, gprod.statusexternerdruck,
          extdruck_color_table, logger
        )
        if stat.status == I18n.t('scopes_names.verschickt_filter')
          gprod.statusexternerdruck = stat
        end
      end

      gprod.save!
    end
  end

	##
	# Rake task for the HIDDEN Satz table
	def rake_satz_table(table)
    logger = Logger.new('log/development_rake.log')
    h = get_col_from_title(table)
		# NOTE: If you want to get the color values (the same way we get the color
		# values for the other tables), you need to merge the GoogleScript API
		# projects, or authorize with another key, to the 'Satz' GoogleScript API
		# project, because google says so: 
		#		https://developers.google.com/apps-script/guides/rest/api -> #Limitations
		# Have fun.
		#
    # Needed for color_from() function.
    #$COLORS = nil
    #$COLOR_D = nil
    #load 'lib/tasks/gapi_get_color_vals.rb'
    #if $COLORS.nil? or $COLOR_D.nil?
    #  puts "Fatal error, could not get Color values from the ./gapi_get_color_vals.rb script."
    #  puts "Exiting, this makes no sense without status information."
    #  exit
    #end

    (2..table.num_rows).each do |i| #skip first line: headers
      buch = find_buch_by_shortisbn(table[i,h['ISBN']], logger) rescue nil
      next if buch.nil?
      gprod = buch.gprod
      if gprod.nil?
        logger.fatal "Buch without gprod -- isbn[#{buch['isbn']}]"
        next
      end

			comment = table[i,h['Kommentar']] rescue nil
			gprod.satz_bemerkungen = comment unless comment.nil?

			status = check_st_satz_entry(table[i,h['st']], logger) rescue nil
			unless gprod.statussatz.nil?
				gprod.statussatz.status = status unless status.nil?
			else
				gprod.statussatz = StatusSatz.new(status: status)
			end

			gprod.satz_bemerkungen = table[i,h['Kommentar']] rescue nil

			gprod.satz_bearbeiter = table[i,h['Bearbeiter']] rescue nil

      sollf = check_date_entry(table[i,h['Fertig_soll']], logger) rescue nil
			gprod.satz_deadline = sollf unless sollf.nil?

			# dauer der korrektur eines werkes
			time = Time.parse table[i,h['Korrekturzeit Autor']] rescue nil
			unless time.nil?
				# not sure why we need that hour..
				gprod.satz_korrektur = time + 1.hour
			end

			gprod.save!
		end # end row iteration
	end

	# Rake task for the HIDDEN SF table
	def rake_sf_table(table)
    logger = Logger.new('log/development_rake.log')
    h = get_col_from_title(table)

    (2..table.num_rows).each do |i| #skip first line: headers
      buch = find_buch_by_shortisbn(table[i,h['ISBN']], logger) rescue nil
      next if buch.nil?
      gprod = buch.gprod
      if gprod.nil?
        logger.fatal "Buch without gprod -- isbn[#{buch['isbn']}]"
        next
      end

			# get only page information, no other garbage from that field..
			vier_farb_pages = table[i,h['vier_farb']] rescue nil
			m = /([0-9 \-,]+)/.match vier_farb_pages
			vier_farb_pages = m[1].strip rescue nil
			buch.vier_farb = vier_farb_pages unless vier_farb_pages.nil?

			pfad = table[i,h['Pfad']] rescue nil
			gprod.satz_pfad = pfad unless pfad.nil?

			gprod.save!
			buch.save!
		end
	end

	# Get klapptext info from that tiny table
  def rake_klapptex_table(table)
    logger = Logger.new('log/development_rake.log')
    h = get_col_from_title(table)
    (2..table.num_rows).each do |i| #skip first line: headers
      buch = find_buch_by_shortisbn(table[i,h['ISBN']], logger) rescue nil
      next if buch.nil?
      gprod = buch.gprod
      if gprod.nil?
        logger.fatal "Buch without gprod -- isbn[#{buch['isbn']}]"
        next
      end

      ['angefordert', 'Eingang', 'Bemerkungen'].each do |headline|
        gprod.klappentextinfo += "#{headline}: #{table[i,h[headline]].to_s}\n"
      end
			# Whoops we dont save here.. but .. hm.. seems to be working anyway,
			# strange.
    end
  end

  ##
  # A task importing ALL data from the google 'Prod' tables.
  desc "Import GoogleSpreadsheet-'Produktionstabellen'-data."
  task import: :environment do
    session = GoogleDrive.saved_session( ".credentials/client_secret.json" )
    spreadsheet = session.spreadsheet_by_key( "1YWWcaEzdkBLidiXkO-_3fWtne2kMgXuEnw6vcICboRc" )
		satz_speadsheet = session.spreadsheet_by_key( "1JWUKZDldb2E6RGaEbEKDLppj5sh04J-YmPRpb0Toe7E" )

    ##
    # We need to set $TABLE which is used as argument for the javascript
    # function call in the google-script API script, getting the color values.
    # (No, there is not one 'script' too much.)

    logger = Logger.new('log/development_rake.log')
    logger.fatal "\n\n=== A new rake task Beginns ==="
    logger.fatal "--- Archiv rake beginns ---"
    $TABLE = 'Archiv'
    table = spreadsheet.worksheet_by_title('Archiv')
    rake_umschlag_table(table, logger)
    logger.fatal "--- UmArchiv rake beginns ---"
    $TABLE = 'UmArchiv'
    table = spreadsheet.worksheet_by_title('UmArchiv')
    rake_umschlag_table(table, logger)
    logger.fatal "--- EinListe rake beginns ---"
    $TABLE = 'EinListe'
    table = spreadsheet.worksheet_by_title('EinListe')
    rake_umschlag_table(table, logger)
    logger.fatal "--- LF rake beginns ---"
    $TABLE = 'LF'
    table = spreadsheet.worksheet_by_title('LF')
    rake_umschlag_table(table, logger)

    logger.fatal "--- Bi rake beginns ---"
    $TABLE = 'Bi'
    table = spreadsheet.worksheet_by_title('Bi')
    rake_bi_table(table)

    logger.fatal "--- Tit rake beginns ---"
    $TABLE = 'Tit'
    table = spreadsheet.worksheet_by_title('Tit')
    rake_tit_table(table)

    logger.fatal "--- ExternerDruck rake beginns ---"
    $TABLE = 'Extern'
    table = spreadsheet.worksheet_by_title('Extern')
    rake_ext_druck_table(table)

    logger.fatal "--- Klappentexte rake beginns ---"
    table = spreadsheet.worksheet_by_title('Klappentexte')
    rake_klapptex_table(table)

    logger.fatal "--- Satz rake beginns ---"
    $TABLE = 'Satz'
		rake_satz_table(satz_speadsheet.worksheet_by_title $TABLE)
    logger.fatal "--- SF rake beginns ---"
    $TABLE = 'SF'
		rake_sf_table(satz_speadsheet.worksheet_by_title $TABLE)

  end # end import-task

	##
	# It follow some of the above bundled tasks separated.
	##

	# Small task only for satz import from their own table, that NO ONE TOLD ME ABOUT.
  desc "Tit table import test"
  task import_satz: :environment do
		session = GoogleDrive.saved_session ".credentials/client_secret.json"
		satz_speadsheet = session.spreadsheet_by_key "1JWUKZDldb2E6RGaEbEKDLppj5sh04J-YmPRpb0Toe7E"
    logger = Logger.new('log/development_rake.log')
    logger.fatal "--- Satz rake beginns ---"
    $TABLE = 'Satz'
		rake_satz_table(satz_speadsheet.worksheet_by_title $TABLE)
    logger.fatal "--- SF rake beginns ---"
    $TABLE = 'SF'
		rake_sf_table(satz_speadsheet.worksheet_by_title $TABLE)
	end
  # Small task only for tit import.
  desc "Tit table import test"
  task import_tit: :environment do
    session = GoogleDrive.saved_session( ".credentials/client_secret.json" )
    spreadsheet = session.spreadsheet_by_key( "1YWWcaEzdkBLidiXkO-_3fWtne2kMgXuEnw6vcICboRc" )
    logger = Logger.new('log/development_rake.log')
    logger.fatal "--- Tit rake beginns ---"
    $TABLE = 'Tit'
    table = spreadsheet.worksheet_by_title('Tit')
    rake_tit_table(table)
  end
  # Another one.. for externer_druck
  desc "ExternerDruck table import test"
  task import_extd: :environment do
    session = GoogleDrive.saved_session( ".credentials/client_secret.json" )
    spreadsheet = session.spreadsheet_by_key( "1YWWcaEzdkBLidiXkO-_3fWtne2kMgXuEnw6vcICboRc" )
    logger = Logger.new('log/development_rake.log')
    logger.fatal "--- ExternerDruck rake beginns ---"
    $TABLE = 'Extern'
    table = spreadsheet.worksheet_by_title('Extern')
    rake_ext_druck_table(table)
  end

  # Unit-testing task.
  desc "Import GoogleSpreadsheet-'Produktionstabellen'-data."
  task test: :environment do
    require 'minitest/autorun'

    class GapiTest < Minitest::Test

      def test_papier_bezeichnung()
        papier_table = {
          '115 matt'=> nil, # ??XXX??
          'o80'     => I18n.t('paper_names.offset80') ,# Offset 80
          '80'      => I18n.t('paper_names.offset80'),
          '80o'     => I18n.t('paper_names.offset80') ,
          'o 80'    => I18n.t('paper_names.offset80') ,
          'o80 $'   => I18n.t('paper_names.offset80') ,
          'o80 y'   => I18n.t('paper_names.offset80') ,
          'o90'     => I18n.t('paper_names.offset90') ,# Offset 90
          'o 90'    => I18n.t('paper_names.offset90') ,
          '90o'     => I18n.t('paper_names.offset90') ,
          'w90 $'   => I18n.t('paper_names.werk90b') , # Werkdruck 90 blau
          'w90 y'   => I18n.t('paper_names.werk90b') ,
          'w90'     => I18n.t('paper_names.werk90b') ,
          'w 90'    => I18n.t('paper_names.werk90b') ,
          '90w'     => I18n.t('paper_names.werk90b') ,
          'wg90 $'  => I18n.t('paper_names.werk90g') , # Werkdruck 90 gelb
          'wg90'    => I18n.t('paper_names.werk90g') ,
          '90wg'    => I18n.t('paper_names.werk90g') ,
          'wg 90'   => I18n.t('paper_names.werk90g') ,
          'wg100'   => I18n.t('paper_names.werk100') , # Werkdruck 100
          'w100'    => I18n.t('paper_names.werk100') , 
        }
        papier_table.to_enum.each do |key, value|
          tok = check_papier_entry(key)
          puts "testing '#{key}' vs '#{value}', is '#{tok}'" if tok != value 
          assert_equal value, tok
        end
      end

      def test_umformat_bezeichnung()
        format_table = {
          'A4'      => I18n.t('format_names.a4'),
          '24x17'   => I18n.t('format_names.sonder24'),
          '23'      => I18n.t('format_names.sonder23'),
          '23x16'   => I18n.t('format_names.sonder23'),
          '23 x 16' => I18n.t('format_names.sonder23'),
          '22x16'   => I18n.t('format_names.sonder22'),
          '22 x 16' => I18n.t('format_names.sonder22'),
          'A5'      => I18n.t('format_names.a5'),
          'a5'      => I18n.t('format_names.a5'),
          '21x14'   => I18n.t('format_names.a5'),
          '21 x 14' => I18n.t('format_names.a5'),
          '21'      => I18n.t('format_names.a5'),
          'A6'      => I18n.t('format_names.a6'),
          'sonder12'=> 'sonder12',
          'sonderlol'=> 'sonderlol',
        }
        format_table.to_enum.each do |key, value|
          tok = check_umformat_entry(key)
          puts "key: '#{key}' should be #{value} and is #{tok}" if tok != value
          assert_equal value, tok
        end
      end

      def test_auflage_entry()
        table = {
          '123(32)' => [123,32],
          '103(60)' => [103,60],
          '103 (60)' => [103,60],
          '100'     => [100,nil],
          '(100)'     => [nil,100],
          '149(1)'  => [149,1],
        }
        table.to_enum.each do |key, value|
          tok = check_auflage_entry(key)
          puts "'#{key}' should be '#{value}' but its '#{tok}'" if tok != value
          assert_equal value, tok
        end
      end

      def test_druck_entry()
        table = {
          'ex x1' => [true,nil,'x1'],
          ' x'    => [nil,'Digitaldruck',nil],
          'x1'    => [nil,nil,'x1'],
          'F1'    => [nil,nil,nil],
        }
        table.to_enum.each do |key, value|
          tok = check_druck_entry(key)
          puts "'#{key}' should be '#{value}' but its '#{tok}'" if tok != value
          assert_equal value, tok
        end
      end

      def test_prio_entry()
        table = {
          'A' => ['A',nil],
          'a' => ['A',nil],
          'ASB' => ['A','Sammelband mit Beiträgerversand'],
          'A:SB' => ['A','Sammelband mit Beiträgerversand'],
          'B Fr:30' => ['B',"Freiexemplare: 30\n"],
          'A pf8 Fr:25' => ['A',"Pflichtexemplare: 8\nFreiexemplare: 25\n"],
        }
        table.to_enum.each do |key, value|
          tok = check_prio_entry(key)
          assert_equal value, tok
        end
      end

      def test_bindung_entry()
        table = {
          'f' => [I18n.t('bi_names.f'),true],
          'K' => [I18n.t('bi_names.k'),false],
          'fhc' => ['faden_hardcover',true],
          'k' => [I18n.t('bi_names.k'),false],
        }
        table.to_enum.each do |key, value|
          tok = check_bindung_entry(key)
          assert_equal value, tok
        end
      end

      def test_date_entry()
        table = {
          '12.12.2013'  => Date.parse('12.12.2013'),
          '2.12.2003'   => Date.parse('2.12.2003'),
          'lolwut'      => nil,
          ''            => nil,
        }
        table.to_enum.each do |key, value|
          tok = check_date_entry(key)
          assert_equal value, tok
        end
      end

      def test_email_entry()
        table = {
          'Fernando Enns <fernando.enns@uni-hamburg.de>' => 
                                              'fernando.enns@uni-hamburg.de',
          '<fernando.enns@uni-hamburg.de>' => 'fernando.enns@uni-hamburg.de',
          'fernando.enns@uni-hamburg.de'   => 'fernando.enns@uni-hamburg.de',
          'opa'                            => nil,
        }
        table.to_enum.each do |key, value|
          tok = check_email_entry(key)
          assert_equal value, tok
        end
      end

#     def test_xxx_entry()
#       table = {
#       }
#       table.to_enum.each do |key, value|
#         tok = check_xxx_entry(key)
#         assert_equal value, tok
#       end
#     end

    end # unittest class

  end # unittest task

end # namespace end
