namespace :gapi do
	require 'logger'

	##
	# A function to map the columns of any 'Lit-produktions-tabelle' to their
	# numeric value.
	def get_col_from_title( table )
		# Build index and name table.
		index = ( 1..table.max_cols ).drop(0)
		name = table.rows[0]
		# Zip them.
		return Hash[*name.zip(index).flatten]
	end

	##
	# This function parses a single entry in the 'produktionstabelle' for the
	# 'Papier'_token. Order important, need to match more specific ones first.
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

	##
	# This function parses a single entry in the 'produktionstabelle' for the
	# 'Bindungs'_token. Same note as above.
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

	##
	# This function parses a single entry in the 'produktionstabelle' for the
	# 'Abteilungs'_token.
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

	##
	# This function parses a single entry in the 'produktionstabelle' for the
	# 'Umschlag-format'_token.
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
	# This script links all the data.
	# We create Gprod objects and search for all the things:
	#   buch | lektor | reihe | autor | ...
	desc "Import GoogleSpreadsheet-'Produktionstabellen'-data."
	task import: :environment do
		session = GoogleDrive.saved_session( ".credentials/client_secret.json" )
		spreadsheet = session.spreadsheet_by_key( "1YWWcaEzdkBLidiXkO-_3fWtne2kMgXuEnw6vcICboRc" )


		##
		# As the ruby GoogleAPI does not support an easy way to access cell
		# formatting.. my prefered option is to write a javascript function,
		# returning a json object, containing color data of one table, which can
		# then be called via an GoogleAPI function call.
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

				##											     ##
				# General book-related data.  #
				##													 ##

				##
				# Error check isbn entries.
				# If we cannot find the ISBN of the book in the database, we bail out.
				short_isbn = table[ i, h['ISBN'] ]
				if short_isbn.nil? or short_isbn.size < 1
					logger.fatal "Strange entry in column #{i.to_s}: "\
											 +"'#{table[i,h['ISBN']]}' \tSKIPPED"
					next
				end
				buch = Buch.where( "isbn like '%#{short_isbn}'" ).first

				# Throw some conditional error/debug messages.
				if (/[0-9]{5}-[0-9]/ =~ short_isbn) == 0				# Normal '12345-6' ISBN?
					if buch.nil?
						logger.fatal "Short ISBN not found: '#{short_isbn}' \tSKIPPED" 
						next
					end
				else
					if (/[0-9]{3}-[0-9]/ =~ short_isbn) == 0			# Maybe ATE/EGL?
						logger.fatal "ATE/EGL short_isbn notation. \tSKIPPED"
						next
					else
						logger.fatal "Strange entry in column #{i.to_s}: '#{table[i,h['ISBN']]}' \tSKIPPED"
						next
					end
				end

				# 'Reihen'-code
				r_code = table[i,h['Reihe']]
				if r_code.empty?
					logger.debug "\t Kein reihenkuerzel gefunden."
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

				##									 ##
				# Cover related data. #
				##									 ##

				# Bindung, Externer Druck?
				bindung, extern = check_bindung_entry( table[i,h['Bi']], logger )
				buch[:bindung_bezeichnung] = bindung unless bindung.nil?
				gprod[:externer_druck] = extern unless extern.nil?

				# Auflage
				auflage = table[i,h['Auflage']].to_i
				# XXX 2 values? What is the meaning of this?
				gprod[:auflage] = auflage

				# Papier
				papier = check_papier_entry( table[i,h['Papier']], logger )
				buch[:papier_bezeichnung] = papier unless papier.nil?

				# Bemerkungen aka Sonder
				gprod[:lektor_bemerkungen_public] = table[i,h['Sonder']]

				# Umschlag Abteilung
				um_abteil = check_abteil_entry( table[i,h['Umschlag']], logger )
				buch[:umschlag_bezeichnung] = um_abteil unless um_abteil.nil?

				# Umschlag Format
				format = check_umformat_entry( table[i,h['Format']], logger )
				buch[:format_bezeichnung] = format unless format.nil?


				##
				# Save 'em, so they get a computed ID, which we need for linking.
				gprod.save
				buch.save

				##											 ##
				# Linking all the things. #
				##											 ##

				# buecher_reihen
				buch.reihe_ids= reihe['id'] unless reihe.nil?

				# autoren_reihen
				reihe.autor_ids= autor['id'] unless autor.nil? or reihe.nil?

				# autoren_buecher
				autor.buch_ids= buch['id'] unless autor.nil?

			end

		end # end import-task

		##
		# Order might be important:
		#		Do 'LF' and 'EinListe' last, because their entries are always
		#		up-to-date and unique.
		table = spreadsheet.worksheet_by_title( 'LF' )
		get_em_all( table )

	end

	##
	# Unittests for the import script.
	#	
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
			end # def test_papier_bezeichnung end

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
			end # def test_format_bezeichnung end

		end # class GapiTest end

	end # task gapi:test end

end # namespace end
