##!/home/developer/.rvm/rubies/ruby-2.2.2/bin/ruby
#
# This script adds all entries from the Google-Spreadsheeds 'Produktions
# Tabelle' to our database.
#
# v in Gemfile
#require 'google_drive'
#require 'rubyXL'

desc "Import GoogleSpreadsheet-'Produktionstabellen'-data."
task import_prod: :import_dbf do

	session = GoogleDrive.saved_session( ".credentials/client_secret.json" )
	spreadsheet = session.spreadsheet_by_key( "1YWWcaEzdkBLidiXkO-_3fWtne2kMgXuEnw6vcICboRc" )

	#NOTE: Should automate the download of the xlxs doc.
	workbook = RubyXL::Parser.parse('tmp/prod.xlxs')

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
	#  be called via an API function call.) .. this function gets an additional
	#  argument: the path to a downloaded xlsx document, containing the same
	#  information.
	def get_em_all( table, xlsx )
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
			# Create a book for each entry in the table.
			# Fill in trivial information.
			buch = Buch.new(
				:name		=> table[ i, h['Name'  ] ],
				:isbn		=> table[ i, h['ISBN'  ] ],
				:seiten => table[ i, h['Seiten'] ],
			)

			# Error check isbn entries.
			isbn = table[ i, h['ISBN'] ]
			puts '[Debug] processing '+isbn.to_s
			if isbn.nil? or isbn.size < 1
				puts '[Debug] Strange entry in column '+i.to_s+': '+table[i,h['ISBN']]
				next
			end
			unless (/[0-9]{5}-[0-9]/ =~ isbn) == 0
				unless (/[0-9]{3}-[0-9]/ =~ isbn) == 0
					#TODO What ate/egl short-isbn noation should we use?
					puts "[Implement] ATE/EGL short-isbn notation. \tSKIPPED"
					next
				else
					puts '[Debug] Strange entry in column '+i.to_s+": '"+table[i,h['ISBN']]+"'\tSKIPPED"
					next
				end
			end

			# Reihe.
			r_code = table[ i, h['Reihe'] ]
			unless r_code.empty?
				buch[:r_code] = r_code
			else
				puts "[Debug] \t Kein reihenkuerzel vorhanden."
			end

			# Lektor.
			fox_name = table[ i, h['Lek'] ]
			lektor = Lektor.where(fox_name: fox_name).first
			unless lektor.nil?
				buch[:lektor_id] = lektor[:id]
			else
				lektor = Lektor.create(
					:fox_name			=> fox_name.downcase,
					:name					=> lektorname[fox_name.downcase],
					:emailkuerzel => lektoremailkuerzel[fox_name.downcase]
				)
			end

			# Autor.
			#  - first try: via email, error check against lektor-mail
			email = table[ i, h['email'] ]
			unless email == lektor[:emailkuerzel]
				autor = Autor.where(email: email).first
				unless autor.nil?
					buch[:autor_id] = autor[:id]
				else
					puts "[Debug] \t Author not existent."
				end
			else
				puts "[Implement] another way to find the author."
			end

			puts "[Debug] \t Saving it:'"+buch[:name].to_s+"'"
			#buch.save
		end

	end

	# Get a 'GoogleDrive::Worksheet' object.
	lf_table = spreadsheet.worksheet_by_title( 'LF' )
	lf_h = get_col_from_title( lf_table )
	get_em_all( lf_table )

	# Checks for new entries in the specified table.
	#  If found, adds their content to the database.
	def update( table )
	end

end
