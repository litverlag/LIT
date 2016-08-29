namespace :gapi do
	require 'logger'
	load 'lib/tasks/gapi_get_color_vals.rb'
	unless COLORS
		puts "Fatal error, could not get Color values from the ./gapi_get_color_vals.rb script."
		puts "Exiting, this makes no sense without status information."
		exit
	end

	# Map the header of each column to the column number.
	def get_col_from_title( table )
		index = ( 1..table.max_cols ).drop(0)
		name = table.rows[0]
		return Hash[*name.zip(index).flatten]
	end


	# Now some functions parsing a single entrys in the 'produktionstabelle'.

	def check_papier_entry( entry , logger=nil )
		tok = nil
		if		entry =~ /o ?80|80 ?o/i;				tok = 'Offset 80g'
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
		if		entry =~ /\+/i ;		tok = 'multi'						; extern = true
		elsif	entry =~ /fhc/i;		tok = 'faden_hardcover'	; extern = true
		elsif	entry =~ /k/i	 ;		tok = 'klebe'						; extern = false
		elsif	entry =~ /f/i	 ;		tok = 'faden'						; extern = true
		elsif entry =~ /h/i	 ;		tok = 'hardcover'				; extern = true
		else
			logger.error "Unknown 'bindung': '#{entry}'" unless logger.nil?
		end
		return tok, extern
	end

	def check_abteil_entry( entry, logger=nil )
		tok = nil
		if		entry =~ /te?x/i;		tok = 'LaTeX'
		elsif entry =~ /in/i;			tok = 'InDesign'
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
		else
			logger.error "Unknown 'Buchformat': '#{entry}'" unless logger.nil?
		end
		return tok
	end

	## 
	# FIXME: 
	#  * Is it possible to have more that one Pflicht-/Sonder-/Vorab-exemplare ??
	#  * Fr:N - no description in Litiki ???
	## 
	def check_prio_entry( entry, logger=nil )
		tok = nil
		sonder = nil
		if		entry =~ /z/i;				tok			= 'Z'
		elsif	entry =~ /a/i;				tok			= 'A'
		elsif entry =~ /b/i;				tok			= 'B'
		elsif entry =~ /c/i;				tok			= 'C'
		else
			logger.error "Unknown 'Prio/Sonder': '#{entry}'" unless logger.nil?
		end
		if		entry =~ /pf/i;				sonder  = 'Pflichtexemplare: '+ /(pf).*?(\d+)/.match(entry)[2]
		elsif entry =~ /sonder/i;		sonder  = 'Sonderexemplare: '+ /(sonder).*?(\d+)/.match(entry)[2]
		elsif entry =~ /vorab/i;		sonder  = 'Vorabexemplare: '+ /(vorab).*?(\d+)/.match(entry)[2]
		elsif entry =~ /fr/i;				sonder  = 'Freiexemplare: '+ /(fr).*?(\d+)/.match(entry)[2]
		elsif entry =~ /m/i;				sonder  = 'Monographie'
		elsif entry =~ /sb/i;				sonder  = 'Sammelband mit Beiträgerversand'
		elsif entry =~ /s/i;				sonder  = 'Sammelband'
		end
		return tok, sonder
	end

	def check_druck_entry( entry, logger=nil )
		tok = nil, bild = nil
		if		entry =~ /^\s*x\s*$/i;		tok = 'Digitaldruck'
		elsif entry =~ /x1/i;						bild = 'x1'
		elsif entry =~ /x2/i;						bild = 'x2'
		elsif entry =~ /x3/i;						bild = 'x3'
		else
			logger.error "Unknown 'druck': '#{entry}'" unless logger.nil?
		end
		return tok, bild
	end

	##
	# FIXME: undocumented entries.. satz? ok?
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

	## EMPTY PROTOTYPE, replace xxx with column name.
	def check_xxx_entry( entry, logger=nil )
		tok = nil
		if		entry =~ //i;		tok = nil
		elsif entry =~ //i;		tok = nil
		else
			logger.error "Unknown 'xxx': '#{entry}'" unless logger.nil?
		end
		return tok
	end

	##
	# A task importing all data from the google 'Prod' tables.
	desc "Import GoogleSpreadsheet-'Produktionstabellen'-data."
	task import: :environment do
		session = GoogleDrive.saved_session( ".credentials/client_secret.json" )
		spreadsheet = session.spreadsheet_by_key( "1YWWcaEzdkBLidiXkO-_3fWtne2kMgXuEnw6vcICboRc" )

		def get_em_all( table )
			logger = Logger.new('log/development_rake.log')
			h = get_col_from_title( table )

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
					autor = Autor.where("name like '#{gprod['projektname']}'").first if autor.nil?
					unless autor.nil?
						buch[:autor_id] = autor[:id]
						gprod[:autor_id] = autor[:id]
					else
						logger.debug "\t Author not existent."
					end
				else
					logger.fatal "The given email does not belong to the author."\
											+"\n\t[!] Implement more searches for the Author-ID. [!]"
				end

				##															 ##
				# Better Code layout beginns here #
				##															 ##

				bindung, extern = check_bindung_entry( table[i,h['Bi']], logger )
				buch[:bindung_bezeichnung] = bindung unless bindung.nil?
				gprod[:externer_druck] = extern unless extern.nil?

				auflage = table[i,h['Auflage']].to_i
				# FIXME: 2 values? What is the meaning of this?
				gprod[:auflage] = auflage

				papier = check_papier_entry( table[i,h['Papier']], logger )
				buch[:papier_bezeichnung] = papier unless papier.nil?

				gprod[:lektor_bemerkungen_public] = table[i,h['Sonder']]

				um_abteil = check_abteil_entry( table[i,h['Umschlag']], logger )
				buch[:umschlag_bezeichnung] = um_abteil unless um_abteil.nil?

				format = check_umformat_entry( table[i,h['Format']], logger )
				buch[:format_bezeichnung] = format unless format.nil?

				prio, sonder = check_prio_entry( table[i,h['Prio/Sond']], logger )
				gprod[:prio] = prio unless prio.nil?
				gprod[:lektor_bemerkungen_public] = sonder unless sonder.nil?

				druck, bilder = check_druck_entry( table[i,h['Druck']], logger )
				gprod[:druck_art] = druck unless druck.nil?
				gprod[:bilder] = bilder unless bilder.nil?

				##
				# Save 'em, so they get a computed ID, which we need for linking.
				# buecher_reihen, autoren_reihen, autoren_buecher
				gprod.save
				buch.save

				buch.reihe_ids= reihe['id'] unless reihe.nil?
				reihe.autor_ids= autor['id'] unless autor.nil? or reihe.nil?
				autor.buch_ids= buch['id'] unless autor.nil?

				##								 ##
				# Color information #
				##								 ##

			end # end row iteration

		end # end get_em_all function

		##
		# Order might be important:
		#		Do 'LF' and 'EinListe' last, because their entries are always
		#		up-to-date and unique.
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
					assert_equal tok, value
				end
			end

			def test_format_bezeichnung()
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
				}
				format_table.to_enum.each do |key, value|
					tok = check_umformat_entry(key)
					puts "key: '#{key}' should be #{value} and is #{tok}" if tok != value
					assert_equal tok, value
				end
			end

		end # unittest class

	end # unittest task

end # namespace end
