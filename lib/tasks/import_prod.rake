##!/home/developer/.rvm/rubies/ruby-2.2.2/bin/ruby
#
# This script adds all entries from the Google-Spreadsheeds 'Produktions
# Tabelle' to our database.
#
# v in Gemfile
#require 'google_drive'
#require 'rubyXL'

namespace :gapi do
	desc "Import GoogleSpreadsheet-'Produktionstabellen'-data."
	task import: :environment do

		session = GoogleDrive.saved_session( ".credentials/client_secret.json" )
		spreadsheet = session.spreadsheet_by_key( "1YWWcaEzdkBLidiXkO-_3fWtne2kMgXuEnw6vcICboRc" )

		# A function to map the columns of any 'Lit-produktions-tabelle'.
		def get_col_from_title( table )
			# Build index and name table.
			index = ( 1..table.max_cols ).drop(0)
			name = table.rows[0]
			
			# Zip them.
			return Hash[*name.zip(index).flatten]
		end


		# Should be used once for the big tables LF/EinListe
		#  This function assumes, that every entry is unique.
		#
		#  As the ruby GoogleAPI does not support an easy way to access cell
		#  formatting.. (Only option is to write a javascript function, which can then
		#  be called via an API function call.) .. 		
		def get_em_all( table ) #, xlxs )
			h = get_col_from_title( table )

			lektorname = {
				'hf'  => 'Hopf',
				'whf' => 'Hopf',
				'ch'	=> 'Unknown_ch',
				'hfch'=> 'wtf_hfch',
				'rai' => 'Rainer',
				'bel' => 'Bellman',
				'opa' => 'Unknown_opa',
				'litb'=> 'Lit Berlin',
				'wla' => 'Lit Wien',
				'web' => 'Unknown_web'
			}

			lektoremailkuerzel = {
				'hf'  => 'hopf@lit-verlag.de',
				'whf' => 'hopf@lit-verlag.de',
				'ch'	=> 'Unknown_ch',
				'hfch'=> 'wtf_is_hfch',
				'rai' => 'rainer@lit-verlag.de',
				'bel' => 'bellmann@lit-verlag.de',
				'opa' => 'Unknown_opa',
				'litb'=> 'berlin@lit-verlag.de',
				'wla' => 'wien@lit-verlag.de',
				'web' => 'Unknown_web'
			}

			(2..table.num_rows).each do |i|
				# Search a book for each entry in the table.
				#  (The first line only contains headers)
				# Create/search Author if not existent.
				# Create/search gprod (Project) and get status via color.. [gAPI-call].
				#														   .. this ^ will be fun ..

				#buch = Buch.new(
					#:seiten => table[ i, h['Seiten'] ],
				#)
				gprod = Gprod.new(
					:projektname	=> table[ i, h['Name'    ] ],
				)

				# Error check isbn entries.
				short_isbn = table[ i, h['ISBN'] ]
				if short_isbn.nil? or short_isbn.size < 1
					Rails.logger.debug '[Debug] Strange entry in column '\
									+i.to_s+': '+table[i,h['ISBN']]+"'\tSKIPPED"
					next
				end
				buch = Buch.where( "isbn like '%"+short_isbn+"'" ).first

				# Throw some conditional error/debug messages.
				if (/[0-9]{5}-[0-9]/ =~ short_isbn) == 0				# Normal '12345-6' ISBN?
					if buch.nil?
						Rails.logger.fatal "[Fatal] Short ISBN not found: '"\
										+short_isbn+"'\tSKIPPED" 
						next
					end
				else
					if (/[0-9]{3}-[0-9]/ =~ short_isbn) == 0			# Maybe ATE/EGL?
						Rails.logger.fatal "[Fatal] ATE/EGL short_isbn notation. \tSKIPPED"
						next
					else
						Rails.logger.debug '[Debug] Strange entry in column '\
										+i.to_s+": '"+table[i,h['ISBN']]+"'\tSKIPPED"
						next
					end
				end

				# Reihen code
				r_code = table[ i, h['Reihe'] ]
				unless r_code.empty?
					buch[:r_code] = r_code
				else
					Rails.logger.debug "[Debug] \t Kein reihenkuerzel gefunden."
				end

				# Lektor ID
				fox_name = table[ i, h['Lek'] ]
				lektor = Lektor.where(fox_name: fox_name).first
				if lektor.nil? # Try again ..
					lektor = Lektor.where(name: lektorname[fox_name.downcase]).first
					if lektor.nil? # And again ..
						lektor = Lektor.where(emailkuerzel: lektormailkuerzel[fox_name.downcase]).first
					end
				end
				unless lektor.nil?
					buch[:lektor_id] = lektor[:id]
				else
					lektor = Lektor.create(
						:fox_name			=> fox_name.downcase,
						:name					=> lektorname[fox_name.downcase],
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
					else
						Rails.logger.debug "[Debug] \t Author not existent."
					end
				else
					Rails.logger.fatal "[Fatal] The given email does not belong to the author."\
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
					Rails.logger.error "[Error] Unknown 'bindung': '"+bindung+"'"
				end
				buch[:bindung_bezeichnung] = bindung
				gprod[:externer_druck] = extern

				# Auflage
				auflage = table[ i, h['Auflage' ] ].to_i
				# Here be error-checks.
				gprod[:auflage] = auflage


				# Papier

				#Rails.logger.info "[Info] \t Saving it:'"+buch[:name].to_s+"'"
				buch.save
			end

		end

		# Checks for new entries in the specified table.
		#  If found, adds their content to the database.
		def update( table )
		end

		# Order might be important:
		#		Do 'LF' and 'EinListe' last, 
		#	because their entries are always up-to-date and unique.
		lf_table = spreadsheet.worksheet_by_title( 'LF' )
		lf_h = get_col_from_title( lf_table )
		get_em_all( lf_table )

	end

end
