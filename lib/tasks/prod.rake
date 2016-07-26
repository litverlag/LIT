#!/home/developer/.rvm/rubies/ruby-2.2.2/bin/ruby
#
# This script adds all entries from the Google-Spreadsheeds 'Produktions
# Tabelle' to our database.
#
require 'google_drive'
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

def debug_gea( i , h )
	puts 'Strange entry in column '+i.to_s+': '+table[i,h]
end

# Should be used once for the big tables LF/EinListe
#  This function assumes, that every entry is unique.
def get_em_all( table )
	h = get_col_from_title( table )

	(1..table.num_rows).each do |i|
		# Create a book for each entry in the table.
		# Fill in trivial information.
		buch = Buch.new(
			:name		=> table[ i, h['Name'  ] ],
			:isbn		=> table[ i, h['ISBN'  ] ],
			:seiten => table[ i, h['Seiten'] ],
		)

		# Error check isbn entries.
		isbn = table[ i, h['ISBN'] ]
		if isbn.match('[0-9]{5}-[0-9]') != isbn
			if isbn.match('[0-9]{3}-[0-9]') != isbn
				#ate/egl
				puts 'ATE/EGL not implemented yet.'
				next
			else
				debug_gea(i,h['ISBN'])
				next
			end
		end

		# Autor ... suchen ...
		# Need to use 'buecher_reihen' table to find the author ..

		buch.save
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
