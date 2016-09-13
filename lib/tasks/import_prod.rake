namespace :gapi do
	require 'logger'
	require 'date'

	# Map the header of each column to the column number.
	def get_col_from_title( table )
		index = ( 1..table.max_cols ).drop(0)
		name = table.rows[0]
		return Hash[*name.zip(index).flatten]
	end


	# Now some functions parsing a single entrys in the 'produktionstabelle'.

	def check_papier_entry( entry , logger=nil )
		tok = nil
		if		entry =~ /o? ?80|80 ?o/i;				tok = 'Offset 80g'
		elsif entry =~ /o ?90|90 ?o/i;				tok = 'Offset 90g'
		elsif entry =~ /(wg ?90)|(90 ?wg)/i;	tok = 'Werkdruck 90g gelb'
		elsif entry =~ /(w ?90)|(90 ?w)/i;		tok = 'Werkdruck 90g blau'
		elsif entry =~ /wg? ?100|100 ?wg?/i;	tok = 'Werkdruck 100g'
		else
			logger.error "Unknown 'papier_bezeichnung': '#{entry}'" unless logger.nil?
		end
		return tok
	end

	def check_bindung_entry( entry , logger=nil )
		tok = nil
		extern = nil
		if		entry =~ /\+/i ;		tok = 'multi: '	+ entry	; extern = true
		elsif	entry =~ /fhc/i;		tok = 'faden_hardcover'	; extern = true
		elsif	entry =~ /k/i	 ;		tok = 'klebe'						; extern = false
		elsif	entry =~ /f/i	 ;		tok = 'faden'						; extern = true
		elsif entry =~ /h/i	 ;		tok = 'hardcover'				; extern = true
		else
			logger.error "Unknown 'bindung': '#{entry}'" unless logger.nil?
		end
		return tok, extern
	end

	def check_um_abteil_entry( entry, logger=nil )
		tok = nil
		if		entry =~ /te?x/i;		tok = 'LaTeX'
		elsif entry =~ /in/i;			tok = 'InDesign'
		elsif entry =~ /neu/i;		tok = 'Neue Reihe'
		elsif entry =~ /autor/i;	tok = 'Geliefert'
		else
			logger.error "Unknown 'umschlag abteilung': '#{entry}'" unless logger.nil?
		end
		return tok
	end

	def check_umformat_entry( entry, logger=nil )
		tok = nil
		if		entry =~ /a3/i;			tok = '297 × 420'#'A3'
		elsif entry =~ /a4/i;			tok = '210 × 297'#'A4'
		elsif entry =~ /a5|21/i;  tok = '147 × 210'#'A5'
		elsif entry =~ /a6/i;			tok = '105 × 148'#'A6'
		elsif entry =~ /24/i;			tok = '170 × 240'#'23'
		elsif entry =~ /23/i;			tok = '162 × 230'#'23'
		elsif entry =~ /22/i;			tok = '160 × 220'#'22'
		elsif entry =~ /sonder/i; tok = entry
		else
			logger.error "Unknown 'Buchformat': '#{entry}'" unless logger.nil?
		end
		return tok
	end

	def check_prio_entry( entry, logger=nil )
		tok = nil
		sonder = ''

		if		entry =~ /z/i;				tok			= 'Z'
		elsif	entry =~ /a/i;				tok			= /(a+)/i.match(entry)[1].upcase
		elsif entry =~ /b/i;				tok			= 'B'
		elsif entry =~ /c/i;				tok			= 'C'
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

		if		entry =~ /m/i;			sonder += 'Monographie'
		elsif entry =~ /sb/i;			sonder += 'Sammelband mit Beiträgerversand'
		elsif entry =~ /s/i;			sonder += 'Sammelband'
		end
		sonder = nil if sonder.empty?
		return tok, sonder
	end

	def check_druck_entry( entry, logger=nil )
		return [nil,nil,nil] if entry.empty?
		ext = nil
		tok = nil
		bild = nil
		if		entry =~ /^\s*x\s*$/i;		tok = 'Digitaldruck'	end
		if		entry =~ /x1/i;						bild = 'x1'
		elsif entry =~ /x2/i;						bild = 'x2'
		elsif entry =~ /x3/i;						bild = 'x3'
		elsif entry =~ /x3/i;						bild = 'x3'
		end
		if		entry =~ /ex/i;						ext = true						end
		if ext.nil? and tok.nil? and bild.nil?
			logger.error "Unknown 'druck': '#{entry}'" unless logger.nil?
		end
		return ext, tok, bild
	end

	##
	# TODO: finish this
	def check_korrektorat_entry( entry, logger=nil )
		tok = nil
		if		entry =~ /0/i;			tok = 'Fertig'
		elsif entry =~ /satz/i;		tok = nil
		elsif entry =~ /ok/i;			tok = nil
		else
			logger.error "Unknown 'korrektorat': '#{entry}'" unless logger.nil?
		end
		return tok
	end

	def check_auflage_entry( entry, logger=nil )
		return entry, nil if entry.class == Fixnum
		match = /\s*?(\d+)\s*?\((\d+)\)/.match(entry)
		unless match.nil?
			auflage = match[1].to_i
			abnahme = match[2].to_i
		else
			match = /.*?(\d+)/.match(entry)
			auflage = match[1].to_i unless match.nil?
		end
		if auflage.nil? and abnahme.nil?
			logger.error "Unknown 'auflage': '#{entry}'" unless logger.nil?
		end
		return auflage, abnahme
	end

	def check_date_entry( entry, logger=nil )
		return nil if entry =~ /author/i or entry.empty?
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

	## EMPTY PROTOTYPE, replace xxx with column name.
#	def check_xxx_entry( entry, logger=nil )
#		tok = nil
#		if		entry =~ //i;		tok = nil
#		elsif entry =~ //i;		tok = nil
#		else
#			logger.error "Unknown 'xxx': '#{entry}'" unless logger.nil?
#		end
#		return tok
#	end

	def find_buch_by_shortisbn(short_isbn, logger)
		if short_isbn.nil? or short_isbn.empty?
			logger.fatal "ISBN: empty? '#{short_isbn}'"
			return nil
		end

		buch = Buch.where( "isbn like '%#{short_isbn}'" ).first
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

	def color_from(row, dict, rowname, abteil, status, table, logger)

		unless row.nil? or dict.nil? or dict[rowname].nil?
			color = $COLOR_D[ $COLORS[row-1][dict[rowname]-1]]
		end

		if color.nil? or table[color.to_s].nil?
			# Log error, and status = 'neu'
			logger.error "Color: '#{rowname}' column: #{row-1}"
			if status.nil?
				status = abteil.create!(status: I18n.t("scopes_names.neu_filter"))
			else
				status['status'] = I18n.t("scopes_names.neu_filter")
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
			'white'				=> I18n.t("scopes_names.neu_filter"),
			'yellow'			=> I18n.t('scopes_names.verschickt_filter'),
			'brown'				=> I18n.t('scopes_names.bearbeitung_filter'),
			'green'				=> I18n.t('scopes_names.fertig_filter'),
			'dark green'	=> I18n.t('scopes_names.fertig_filter'),
			'pink'				=> I18n.t('scopes_names.problem_filter'), }
		umschlag_color_table = {
			'white'				=> I18n.t("scopes_names.neu_filter"),
			'yellow'			=> I18n.t('scopes_names.verschickt_filter'),
			'brown'				=> I18n.t('scopes_names.bearbeitung_filter'),
			'green'				=> I18n.t('scopes_names.fertig_filter'),
			'dark green'	=> I18n.t('scopes_names.fertig_filter'),
			'turquois'		=> I18n.t('scopes_names.problem_filter'), }
		lektorname = {
			'hf'			=> 'Hopf',
			'whf'			=> 'Hopf',
			'ch'			=> 'Unknown_ch',
			'hfch'		=> 'wtf_hfch',
			'rai'			=> 'Rainer',
			'rainer'  => 'Rainer',
			'berlin'  => 'Berlin',
			'rit'			=> 'Richter',
			'bel'			=> 'Bellman',
			'opa'			=> 'Unknown_opa',
			'litb'		=> 'Lit Berlin',
			'wien'		=> 'Wien',
			'wla'			=> 'Lit Wien',
			'web'			=> 'Unknown_web' }
		lektoremailkuerzel = {
			'hf'  => 'hopf@lit-verlag.de',
			'whf' => 'hopf@lit-verlag.de',
			'ch'	=> 'Unknown_ch@invalid.com',
			'hfch'=> 'wtf_is_hfch@invalid.com',
			'rai' => 'rainer@lit-verlag.de',
			'rit' => 'richter@lit-verlag.de',
			'bel' => 'bellmann@lit-verlag.de',
			'opa' => 'Unknown_opa@invalid.com',
			'litb'=> 'berlin@lit-verlag.de',
			'wla' => 'wien@lit-verlag.de',
			'wien'=> 'wien@lit-verlag.de',
			'web' => 'Unknown_web@invalid.com' }

		(2..table.num_rows).each do |i| #skip first line: headers
			gprod = Gprod.new( :projektname	=> table[i,h['Name']] ) rescue nil
			if gprod.nil?
				logger.fatal "Table entry 'Name' not found. Someone messed it up?"
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

			# Lektor ID		-->		Buch && Lektor !
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
					:fox_name			=> fox_name.downcase,
					:name					=> 'Unknown_'+fox_name.downcase,
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
				logger.error "Author not found, any ideas? [1]"
			end

			seiten = /\s*(\d*)\s*W?\s*(\d*)/i.match(table[i,h['Seiten']]) rescue nil
			if not seiten.nil? or not seiten[2].nil?
				buch[:seiten] = seiten[2].to_i
			elsif seiten
				buch[:seiten] = seiten[1].to_i
			else
				logger.error "Could not undertstand 'Seiten' entry: col[#{i}]"
			end

			##															 ##
			# Better Code layout beginns here #
			##															 ##

			bindung, extern = check_bindung_entry( table[i,h['Bi']], logger ) rescue nil
			buch[:bindung_bezeichnung] = bindung unless bindung.nil?
			gprod[:externer_druck] = extern unless extern.nil?

			auflage, abnahme = check_auflage_entry( table[i,h['Auflage']].to_i, logger ) rescue nil
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

			##								 ##
			# Color information #
			##								 ##
			#

			gprod.statuspreps = color_from(i, h, 'Papier', StatusPreps,
																		 gprod.statuspreps, general_color_table,
																		 logger)
			gprod.statustitelei = color_from(i, h, 'Titelei', StatusTitelei,
																			 gprod.statustitelei,
																			 general_color_table, logger)

			# TODO: Oh my.. there is no class/status/anything for 'klappentexte'
			#				Need to add this soon..
			format_color = $COLOR_D[ $COLORS[i-1][h['Format']-1]] rescue nil
			if ['green','brown','pink'].include? format_color
				buch[:klappentext] = true
			elsif ['dark green'].include? format_color
				buch[:klappentext] = false
			end

			#	TODO:	Same here ^
			#seiten_color = $COLOR_D[ $COLORS[i-1][h['Seiten']-1]]

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
			unless gprod.final_deadline.nil?
				if gprod.final_deadline.compare_with_coercion(Date.today) == -1
					status = true
				else
					status = false
				end

				unless gprod.statusfinal.nil?
					gprod.statusfinal['freigabe'] = status
				else
					gprod.statusfinal = StatusFinal.create!(freigabe: status)
				end
			end

			##
			# Save 'em, so they get a computed ID, which we need for linking.
			gprod.save!
			buch.save!

			gprod.buch = buch if gprod.buch.nil?
			buch.gprod = gprod if gprod.buch.nil? # we rly need this? 

			buch.reihe_ids= reihe['id'] unless reihe.nil?
			reihe.autor_ids= autor['id'] unless autor.nil? or reihe.nil?
			autor.buch_ids= buch['id'] unless autor.nil?

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
			'white'				=> I18n.t('scopes_names.neu_filter'),
			'yellow'			=> I18n.t('scopes_names.verschickt_filter'),
			'brown'				=> I18n.t('scopes_names.bearbeitung_filter'),
			'green'				=> I18n.t('scopes_names.fertig_filter'),
			'pink'				=> I18n.t('scopes_names.problem_filter'), }

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

			gprod.statusbinderei = color_from(i, h, 'Name', StatusBi,
																				gprod.statusbinderei,
																				general_color_table, logger)

			gprod.save!

		end
	end # end rake_bi_table

	##
	# A task importing ALL data from the google 'Prod' tables.
	desc "Import GoogleSpreadsheet-'Produktionstabellen'-data."
	task import: :environment do
		session = GoogleDrive.saved_session( ".credentials/client_secret.json" )
		spreadsheet = session.spreadsheet_by_key( "1YWWcaEzdkBLidiXkO-_3fWtne2kMgXuEnw6vcICboRc" )

		##
		#	We need to set $TABLE which is used as argument for the javascript
		#	function call in the google-script API script, getting the color values.

		logger = Logger.new('log/development_rake.log')
		logger.fatal "\n=== A new rake task Beginns ===\n"
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

	end # end import-task

	# Unit-testing task.
	desc "Import GoogleSpreadsheet-'Produktionstabellen'-data."
	task test: :environment do
    require 'minitest/autorun'
		class GapiTest < Minitest::Test

			def test_papier_bezeichnung()
				papier_table = {
					'115 matt'=> nil, # ??XXX??
					'o80'			=> 'Offset 80g' ,					# Offset 80
					'80'			=> 'Offset 80g',
					'80o'			=> 'Offset 80g' ,
					'o 80'		=> 'Offset 80g' ,
					'o80 $'		=> 'Offset 80g' ,
					'o80 y'		=> 'Offset 80g' ,
					'o90'			=> 'Offset 90g' ,					# Offset 90
					'o 90'		=> 'Offset 90g' ,
					'90o'			=> 'Offset 90g' ,
					'w90 $'		=> 'Werkdruck 90g blau' , # Werkdruck 90 blau
					'w90 y'		=> 'Werkdruck 90g blau' ,
					'w90'			=> 'Werkdruck 90g blau' ,
					'w 90'		=> 'Werkdruck 90g blau' ,
					'90w'			=> 'Werkdruck 90g blau' ,
					'wg90 $'	=> 'Werkdruck 90g gelb' , # Werkdruck 90 gelb
					'wg90'		=> 'Werkdruck 90g gelb' ,
					'90wg'		=> 'Werkdruck 90g gelb' ,
					'wg 90'		=> 'Werkdruck 90g gelb' ,
					'wg100'		=> 'Werkdruck 100g' ,			# Werkdruck 100
					'w100'		=> 'Werkdruck 100g' , 
				}
				papier_table.to_enum.each do |key, value|
					tok = check_papier_entry(key)
					puts "testing '#{key}' vs '#{value}', is '#{tok}'" if tok != value 
					assert_equal value, tok
				end
			end

			def test_umformat_bezeichnung()
				format_table = {
					'A4'			=> '210 × 297',
					'24x17'		=> '170 × 240',
					'23'			=> '162 × 230',
					'23x16'		=> '162 × 230',
					'23 x 16'	=> '162 × 230',
					'22x16'		=> '160 × 220',
					'22 x 16'	=> '160 × 220',
					'A5'			=> '147 × 210',
					'a5'			=> '147 × 210',
					'21x14'		=> '147 × 210',
					'21 x 14'	=> '147 × 210',
					'21'			=> '147 × 210',
					'A6'			=> '105 × 148',
					'sonder12'=> 'sonder12',
				}
				format_table.to_enum.each do |key, value|
					tok = check_umformat_entry(key)
					puts "key: '#{key}' should be #{value} and is #{tok}" if tok != value
					assert_equal value, tok
				end
			end

			def test_auflage_entry()
				table = {
					'123(32)'	=> [123,32],
					'103(60)' => [103,60],
					'100'			=> [100,nil],
					'149(1)'	=> [149,1],
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
					' x'		=> [nil,'Digitaldruck',nil],
					'x1'		=> [nil,nil,'x1'],
					'F1'		=> [nil,nil,nil],
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
					'f' => ['faden',true],
					'K' => ['klebe',false],
					'fhc' => ['faden_hardcover',true],
					'k' => ['klebe',false],
				}
				table.to_enum.each do |key, value|
					tok = check_bindung_entry(key)
					assert_equal value, tok
				end
			end

			def test_date_entry()
				table = {
					'12.12.2013'	=> Date.parse('12.12.2013'),
					'2.12.2003'		=> Date.parse('2.12.2003'),
					'lolwut'			=> nil,
					''						=> nil,
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
					'opa'														 => nil,
				}
				table.to_enum.each do |key, value|
					tok = check_email_entry(key)
					assert_equal value, tok
				end
			end

#			def test_xxx_entry()
#				table = {
#				}
#				table.to_enum.each do |key, value|
#					tok = check_xxx_entry(key)
#					assert_equal value, tok
#				end
#			end

			# NOTE not finished.. need to provide proper fixtures
			def test_the_real_thing()
				session = GoogleDrive.saved_session(".credentials/client_secret.json")
				spreadsheet = session.spreadsheet_by_key("1YWWcaEzdkBLidiXkO-_3fWtne2kMgXuEnw6vcICboRc")

				logger = Logger.new($stdout)
				$TABLE = 'Unittests'
				table = spreadsheet.worksheet_by_title('Unittests')
				rake_umschlag_table(table, logger)
			end

		end # unittest class

	end # unittest task

end # namespace end
