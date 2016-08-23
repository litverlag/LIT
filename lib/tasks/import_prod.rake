namespace :gapi do
	require 'logger'
	logger = Logger.new('log/development_rake.log')

	##
	# A function to map the columns of any 'Lit-produktions-tabelle'.
	def get_col_from_title( table )
		# Build index and name table.
		index = ( 1..table.max_cols ).drop(0)
		name = table.rows[0]
		# Zip them.
		return Hash[*name.zip(index).flatten]
	end

	##
	# This function parses a single entry in the 'produktionstabelle' for the
	# paper_token.
	def check_papier_entry( entry , logger=nil )
		tok = ''
		if		entry =~ /o ?80|80 ?o/i;				tok = 'Offset 80g'
		elsif entry =~ /o ?90|90 ?o/i;				tok = 'Offset 90g'
		elsif entry =~ /(w ?90)|(90 ?w)/i;				tok = 'Werkdruck 90g blau'
		elsif entry =~ /(wg ?90)|(90 ?wg)/i;			tok = 'Werkdruck 90g gelb'
		elsif entry =~ /wg? ?100|100 ?wg?/i;	tok = 'Werkdruck 100g'
		else
			unless logger.nil?
				logger.error "[Error] Unknown 'papier_bezeichnung': '"\
											+entry+"'"+" in row "+i.to_s
			end
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


			format_table = { # .. should 've used regex ..
				'A4'			=> '210 x 297',
				'24x17'		=> '170 x 240',		# <- strange
				'23'			=> '162 x 230',		# <- strange
				'23x16'		=> '162 x 230',		# <- strange
				'23 x 16'	=> '162 x 230',		# <- strange
				'22x16'		=> '160 x 220',		# <- strange
				'22 x 16'	=> '160 x 220',		# <- strange
				'A5'			=> '147 x 210',
				'a5'			=> '147 x 210',
				'21x14'		=> '147 x 210',
				'21 x 14'	=> '147 x 210',
				'21'			=> '147 x 210',
				'A6'			=> '105 x 148' }	# <- almonst never in use

			(2..table.num_rows).each do |i| #skip first line: headers
				gprod = Gprod.new( :projektname	=> table[i,h['Name']] )


												 ##											     ##
												 # General book-related data. #
												 ##													 ##

				# Error check isbn entries.
				short_isbn = table[ i, h['ISBN'] ]
				if short_isbn.nil? or short_isbn.size < 1
					logger.debug '[Debug] Strange entry in column '\
									+i.to_s+': '+table[i,h['ISBN']]+"'\tSKIPPED"
					next
				end
				buch = Buch.where( "isbn like '%"+short_isbn+"'" ).first

				# Throw some conditional error/debug messages.
				if (/[0-9]{5}-[0-9]/ =~ short_isbn) == 0				# Normal '12345-6' ISBN?
					if buch.nil?
						logger.fatal "[Fatal] Short ISBN not found: '"\
										+short_isbn+"'\tSKIPPED" 
						next
					end
				else
					if (/[0-9]{3}-[0-9]/ =~ short_isbn) == 0			# Maybe ATE/EGL?
						logger.fatal "[Fatal] ATE/EGL short_isbn notation. \tSKIPPED"
						next
					else
						logger.debug '[Debug] Strange entry in column '\
										+i.to_s+": '"+table[i,h['ISBN']]+"'\tSKIPPED"
						next
					end
				end

				# Reihen code
				r_code = table[ i, h['Reihe'] ]
				unless r_code.empty?
					buch[:r_code] = r_code
				else
					logger.debug "[Debug] \t Kein reihenkuerzel gefunden."
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
						"[Info] Strange: We needed to create a missing lektor: '"+fox_name+"'"
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
						logger.debug "[Debug] \t Author not existent."
					end
				else
					logger.fatal \
						"[Fatal] The given email does not belong to the author."\
						+"\n\t Implement more searches for the Author-ID."
				end

				# Bindung, Externer Druck?
				bindung = table[ i, h['Bi'] ]
				if		bindung =~ /\+/i ;		bindung = 'multi'						; extern = true
				elsif	bindung =~ /fhc/i;		bindung = 'faden_hardcover'	; extern = true
				elsif	bindung =~ /k/i	 ;		bindung = 'klebe'						; extern = false
				elsif	bindung =~ /f/i	 ;		bindung = 'faden'						; extern = true
				elsif bindung =~ /h/i	 ;		bindung = 'hardcover'				; extern = true
				else
					bindung = 'unknown'
					logger.error "[Error] Unknown 'bindung': '"+bindung+"'"\
						+" in row "+i.to_s
				end
				buch[:bindung_bezeichnung] = bindung
				gprod[:externer_druck] = extern

				# Auflage
				auflage = table[i,h['Auflage']].to_i
				# 2 values? What is the meaning of this?
				gprod[:auflage] = auflage

				# Papier
				papier = check_papier_entry( table[i,h['Papier']], logger )
				buch[:papier_bezeichnung] = papier unless papier.nil?

				# Bemerkungen aka Sonder
				gprod[:lektor_bemerkungen_public] = table[i,h['Sonder']]


														##									 ##
														# Cover related data. #
														##									 ##

				# Umschlag Abteilung
				um_abteil = table[i,h['Umschlag']]
				if		um_abteil =~ /te?x/i;			um_abteil = 'LaTeX'
				elsif um_abteil =~ /in/i;			um_abteil = 'InDesign'
				elsif um_abteil =~ /autor/i;	um_abteil = 'Geliefert'
				else
					logger.error \
						"[Error] Unknown 'umschlag abteilung': '"+um_abteil+"'"+" in row "+i.to_s
					um_abteil = nil 
				end
				buch[:umschlag_bezeichnung] = um_abteil

				# Umschlag Format
				format = format_table[ table[i,h['Format']] ]
				unless format.nil?
					buch[:format_bezeichnung] = format
				else
					logger.error \
						"[Error] Unknown 'Buchformat': '"+table[i,h['Format']]+"'"+" in row "+i.to_s
				end


				##
				# Save 'em.
				gprod.save
				buch.save

				##
				# TODO: project status and id_* linking
				# 
			end

		end

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
					'115 matt'=> '', # ??XXX??
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
					assert_equal check_papier_entry(key), value
				end
			end # def test_papier_bezeichnung end

		end # class GapiTest end

	end # task gapi:test end

end # namespace end
