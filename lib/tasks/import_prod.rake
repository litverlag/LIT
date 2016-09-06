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
			sonder += 'Pflichtexemplare: '+ tmp[2] +"\n" unless tmp[2].nil?
		end
		unless (tmp = /(sonder).*?(\d+)/i.match(entry)).nil?
			sonder += 'Sonderexemplare: '+ tmp[2] +"\n" unless tmp[2].nil?
		end
		unless (tmp = /(vorab).*?(\d+)/i.match(entry)).nil?
			sonder += 'Vorabexemplare: '+ tmp[2] +"\n" unless tmp[2].nil?
		end
		unless (tmp = /(fr).*?(\d+)/i.match(entry)).nil?
			sonder += 'Freiexemplare: '+ tmp[2] +"\n" unless tmp[2].nil?
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

	##
	# A task importing all data from the google 'Prod' tables.
	desc "Import GoogleSpreadsheet-'Produktionstabellen'-data."
	task import: :environment do
		session = GoogleDrive.saved_session( ".credentials/client_secret.json" )
		spreadsheet = session.spreadsheet_by_key( "1YWWcaEzdkBLidiXkO-_3fWtne2kMgXuEnw6vcICboRc" )

		def get_em_all( table )
			logger = Logger.new('log/development_rake.log')
			h = get_col_from_title( table )

			$COLORS = nil
			$COLOR_D = nil
			load 'lib/tasks/gapi_get_color_vals.rb'
			if $COLORS.nil? or $COLOR_D.nil?
				puts "Fatal error, could not get Color values from the ./gapi_get_color_vals.rb script."
				puts "Exiting, this makes no sense without status information."
				exit
			end

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
				'ch'	=> 'Unknown_ch',
				'hfch'=> 'wtf_is_hfch',
				'rai' => 'rainer@lit-verlag.de',
				'rit' => 'richter@lit-verlag.de',
				'bel' => 'bellmann@lit-verlag.de',
				'opa' => 'Unknown_opa',
				'litb'=> 'berlin@lit-verlag.de',
				'wla' => 'wien@lit-verlag.de',
				'wien'=> 'wien@lit-verlag.de',
				'web' => 'Unknown_web' }

			(2..table.num_rows).each do |i| #skip first line: headers
				gprod = Gprod.new( :projektname	=> table[i,h['Name']] )

				##
				# If we cannot find the ISBN of the book in the database, we bail out.
				short_isbn = table[ i, h['ISBN'] ]
				if short_isbn.nil? or short_isbn.size < 1
					logger.fatal "Strange entry in column #{i.to_s}: "\
											 +"'#{short_isbn}' \tSKIPPED"
					next
				end
				buch = Buch.where( "isbn like '%#{short_isbn}'" ).first

				if (/[0-9]{5}-[0-9]/ =~ short_isbn) == 0
					if buch.nil?
						logger.fatal "Short ISBN not found: '#{short_isbn}' \tSKIPPED" 
						next
					end
				else
					if (/[0-9]{3}-[0-9]/ =~ short_isbn) == 0
						logger.fatal "ATE/EGL short_isbn notation not implemented '#{short_isbn}' \tSKIPPED"
						next
					else
						logger.fatal "Strange entry in column #{i.to_s}: '#{short_isbn}' \tSKIPPED"
						next
					end
				end

				# 'Reihen'-code
				r_code = table[i,h['Reihe']]
				if r_code.empty?
					logger.debug "\t Kein reihenkuerzel gefunden, das feld ist leer."
				else
					buch[:r_code] = r_code.downcase
					reihe = Reihe.where(r_code: r_code.downcase).first
				end

				# Lektor ID		-->		Buch && Lektor !
				fox_name = table[ i, h['Lek'] ]
				lektor = Lektor.where(fox_name: fox_name).first
				if lektor.nil? # Try again ..
					lektor = Lektor.where(name: lektorname[fox_name.downcase]).first
					if lektor.nil? # And again ..
						lektor = Lektor.where(emailkuerzel: lektoremailkuerzel[fox_name.downcase]).first
					end
				end
				unless lektor.nil?
					buch[:lektor_id] = lektor[:id]
					gprod[:lektor_id] = lektor[:id]
				else
					logger.info \
						"Strange: We needed to create a missing lektor: '#{fox_name}'"
					lektor = Lektor.create(
						:fox_name			=> fox_name.downcase,
						:name					=> 'Unknown_'+fox_name.downcase,
						:emailkuerzel => lektoremailkuerzel[fox_name.downcase]
					)
				end

				# Autor ID and Projekt E-Mail
				email = table[ i, h['email'] ]
				if email.nil? or email.empty?
					email = lektor[:emailkuerzel]				# This will log a fatal error below.
				end
				gprod[:projekt_email_adresse] = email
				unless email == lektor[:emailkuerzel] # email from Table does not belong to author.
					autor = Autor.where(email: email).first
					autor = Autor.where("name like '%#{gprod['projektname']}%'").first if autor.nil?
					unless autor.nil?
						buch[:autor_id] = autor[:id]
						gprod[:autor_id] = autor[:id]
					else
						logger.error "Author not found, any ideas? [1]"
					end
				else
					logger.error "Author not found, any ideas? [1]"
				end

				seiten = /\s*(\d*)\s*W?\s*(\d*)/i.match(table[i,h['Seiten']])
				if not seiten.nil? or not seiten[2].nil?
					buch[:seiten] = seiten[2].to_i
				elsif seiten
					buch[:seiten] = seiten[1].to_i
				else
					logger.error "Could not undertstand 'Seiten' entry: '#{table[i,h['Seiten']]}'"
				end

				##															 ##
				# Better Code layout beginns here #
				##															 ##

				bindung, extern = check_bindung_entry( table[i,h['Bi']], logger )
				buch[:bindung_bezeichnung] = bindung unless bindung.nil?
				gprod[:externer_druck] = extern unless extern.nil?

				auflage, abnahme = check_auflage_entry( table[i,h['Auflage']].to_i, logger )
				gprod[:auflage] = auflage unless auflage.nil?
				gprod[:gesicherte_abnahme] = abnahme unless abnahme.nil?

				papier = check_papier_entry( table[i,h['Papier']], logger )
				buch[:papier_bezeichnung] = papier unless papier.nil?

				gprod[:lektor_bemerkungen_public] = table[i,h['Sonder']]

				um_abteil = check_um_abteil_entry( table[i,h['Umschlag']], logger )
				buch[:umschlag_bezeichnung] = um_abteil unless um_abteil.nil?

				format = check_umformat_entry( table[i,h['Format']], logger )
				buch[:format_bezeichnung] = format unless format.nil?

				prio, sonder = check_prio_entry( table[i,h['Prio/Sond']], logger )
				gprod[:prio] = prio unless prio.nil?
				gprod[:lektor_bemerkungen_public] = sonder unless sonder.nil?

				extern, druck, bilder = check_druck_entry( table[i,h['Druck']], logger )
				gprod[:externer_druck] = extern unless extern.nil?
				gprod[:druck_art] = druck unless druck.nil?
				gprod[:bilder] = bilder unless bilder.nil?

				msein = check_date_entry( table[i,h['MsEin']], logger )
				gprod.manusskript_eingang_date = msein unless msein.nil?

				sollf = check_date_entry( table[i,h['SollF']], logger )
				gprod.final_deadline = sollf unless sollf.nil?

				##								 ##
				# Color information #
				##								 ##
				#

				general_color_table = {
					'white'				=> I18n.t("scopes_names.neu_filter"),
					'yellow'			=> I18n.t('scopes_names.verschickt_filter'),
					'brown'				=> I18n.t('scopes_names.bearbeitung_filter'),
					'green'				=> I18n.t('scopes_names.fertig_filter'),
					'dark green'	=> I18n.t('scopes_names.fertig_filter'),
					'pink'				=> I18n.t('scopes_names.problem_filter'),
				}
				umschlag_color_table = {
					'white'				=> I18n.t("scopes_names.neu_filter"),
					'yellow'			=> I18n.t('scopes_names.verschickt_filter'),
					'brown'				=> I18n.t('scopes_names.bearbeitung_filter'),
					'green'				=> I18n.t('scopes_names.fertig_filter'),
					'dark green'	=> I18n.t('scopes_names.fertig_filter'),
					'turquois'		=> I18n.t('scopes_names.problem_filter'),
				}

				papier_color = $COLOR_D[ $COLORS[i-1][h['Papier']-1]]
				if papier_color.nil?
					logger.error "Could not determine paper color for column: #{i}"
				elsif gprod.statuspreps.nil?
					gprod.statuspreps = StatusPreps.create(status: general_color_table[papier_color])
				else
					gprod.statuspreps['status'] = general_color_table[papier_color]
				end

				titelei_color = $COLOR_D[ $COLORS[i-1][h['Titelei']-1]]
				if titelei_color.nil?
					logger.error "Could not determine titelei color for column: #{i}"
				elsif gprod.statustitelei.nil?
					gprod.statustitelei = StatusTitelei.create(status: general_color_table[titelei_color])
				else
					gprod.statustitelei['status'] = general_color_table[titelei_color]
				end

				# TODO: Oh my.. there is no class/status/anything for 'klappentexte'
				#				Need to add this soon..
				format_color = $COLOR_D[ $COLORS[i-1][h['Format']-1]]
				if ['green','brown','pink'].include? format_color
					buch[:klappentext] = true
				elsif ['dark green'].include? format_color
					buch[:klappentext] = false
				end

				#	TODO:	Same here ^
				#seiten_color = $COLOR_D[ $COLORS[i-1][h['Seiten']-1]]

				umschlag_color = $COLOR_D[ $COLORS[i-1][h['Umschlag']-1]]
				if umschlag_color.nil?
					logger.error "Could not determine 'Umschlag' color for column: #{i-1}"
				elsif gprod.statusumschl.nil?
					gprod.statusumschl = StatusUmschl.create(status: umschlag_color_table[umschlag_color])
				else
					gprod.statusumschl['status'] = umschlag_color_table[umschlag_color]
				end

				name_color = $COLOR_D[ $COLORS[i-1][h['Name']-1]]
				if name_color.nil?
					logger.error "Could not determine 'Name' color for column: #{i-1}"
				else
					gprod[:satzproduktion] = true if name_color == 'light pink'
				end

				satz_color = $COLOR_D[ $COLORS[i-1][h['Satz']-1]]
				if satz_color.nil?
					logger.error "Could not determine 'Satz' color for column: #{i-1}"
				elsif gprod.statussatz.nil?
					gprod.statussatz = StatusSatz.create(status: general_color_table[satz_color])
				else
					gprod.statussatz['status'] = general_color_table[satz_color]
				end

				druck_color = $COLOR_D[ $COLORS[i-1][h['Druck']-1]]
				if druck_color.nil?
					logger.error  "Could not determine 'Druck' color for column: #{i-1}"
				elsif druck_color == 'green'
					if gprod.statusdruck.nil?
						gprod.statusdruck = StatusDruck.create(status: I18n.t('scopes_names.fertig_filter'))
					else
						gprod.statusdruck['status'] = I18n.t('scopes_names.fertig_filter')
					end
				end

				gprod.buch = buch

				##
				# Save 'em, so they get a computed ID, which we need for linking.
				gprod.save
				buch.save

				buch.reihe_ids= reihe['id'] unless reihe.nil?
				reihe.autor_ids= autor['id'] unless autor.nil? or reihe.nil?
				autor.buch_ids= buch['id'] unless autor.nil?

				gprod.save
				buch.save
				# Save 'em again.
				##

			end # end row iteration

		end # end get_em_all function

		##
		#	Do 'LF' and 'EinListe' last, because their entries are always up-to-date
		#	and unique. 
		#	We need to set $TABLE as its used as argument for the javascript function
		#	call in the google-script API script, getting the color values.
		$TABLE = 'EinListe'
		table = spreadsheet.worksheet_by_title( 'EinListe' )
		get_em_all( table )
		$TABLE = 'LF'
		table = spreadsheet.worksheet_by_title( 'LF' )
		get_em_all( table )

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

#			def test_xxx_entry()
#				table = {
#				}
#				table.to_enum.each do |key, value|
#					tok = check_xxx_entry(key)
#					assert_equal value, tok
#				end
#			end

			def test_api_call()
				session = GoogleDrive.saved_session( ".credentials/client_secret.json" )
				spreadsheet = session.spreadsheet_by_key( "1YWWcaEzdkBLidiXkO-_3fWtne2kMgXuEnw6vcICboRc" )
				table = spreadsheet.worksheet_by_title( 'EinListe' )
				h = get_col_from_title( table )

				$TABLE = 'EinListe'
				load 'lib/tasks/gapi_get_color_vals.rb'

				assert_equal '#b7e1cd', $COLORS[0][0]

				##
				# Uncomment the following and run 'bin/rake gapi:test' to see that i
				# did everything right.
				##

				#i = 1
				#puts "line number <#{i}>, header number <#{h['ID']}>, contains '#{table[i,h['ID']]}'"
				#puts "and color #{$COLORS[i-1][h['ID']-1]}"
			end

		end # unittest class

	end # unittest task

end # namespace end
