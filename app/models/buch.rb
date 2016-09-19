##
# # /app/models/buch.rb
#
# Represents a book. And is associated with reihe, autor, gprod, lektor.
class Buch < ActiveRecord::Base
	include ActiveModel::Validations

  has_and_belongs_to_many :reihen
  accepts_nested_attributes_for :reihen

  has_and_belongs_to_many :autoren
  accepts_nested_attributes_for :autoren

  belongs_to :gprod
  belongs_to :lektor

  ##
  # Checks if the ISBN is corrent makes use of the LISBN gem
	#
	## Who wrote this bullshit? How about we dont assume that the isbn data in
	##  the database is incomplete?
	## Fixed.
  def short_isbn
		i = Lisbn.new(self.isbn)					if (/\d{3}-\d-\d{3}-\d+/ =~ self.isbn)==0
		i = Lisbn.new("978-#{self.isbn}") if (			/\d-\d{3}-\d+/ =~ self.isbn)==0

		if i.valid?
			"#{i.parts[3]}-#{i.parts[4]}"
		else
			"#WrongFormat: '"+self.isbn+"'"
		end
  end

  ##
  # all_attributes_set? checks if there is at least one nil attribute in the table.
  # Notice that here the field lektor_id and autor_id are hardcoded but you can remove them
  # if the entries are removed from the Database table
  def all_attributes_set?
    all_attri = true
    self.attributes.each do |key,value|
      next if key.eql?("lektor_id") | key.eql?("autor_id")
      if value.blank?
        all_attri = false
      end
    end
    return all_attri
  end

	##
	# Computes the backsize
	def backsize
		gprod = Gprod.where(id: self[:gprod_id])
		if gprod[:externer_druck] then return nil end
		pages = self[:seiten]
		papertype = self[:papier_bezeichnung]
		factor = factor_table[ papertype ]
		sz = pages * factor
		unless sz.round <= sz
			return sz.round
		else
			return sz.round + 1
		end
	end

	factor_table = {
		'Offset 80g'          => 0.05 ,
		'Offset 90g'					=> 0.06 ,
		'Werkdruck 90g blau'  => 0.055,
		'Werkdruck 100g'      => 0.06 ,
		'KunstdruckMatt'			=> 0.05 ,
		'Werkdruck 90g gelb'  => 0.055 }

## Python code for backsize computation.
# try: # [papertype.lower()[:3]] cause "w90 $", what is this madness..
#     factor = papierWerteFaktoren[papertype.lower()[:3]][bindung[0].lower()]
# except KeyError:
#     print('Catched KeyError: Vermutlich externer Druck.')
#     print('Bindung:',bindung[0].lower())
#     exit(-1)
# backsize = pages * factor
# # always round up
# if round(backsize) <= backsize:
#     backsize = round(backsize)+1
# else:
#     # if back is small AND we round up just a little just add 1
#     if backsize <= 15 and round(backsize) - backsize <= 0.20:
# 	backsize = round(backsize) + 1
#     else:
# 	backsize = round(backsize)
# 
# if bindung.lower()[0] in print_here:
#     print( '%.4f' %backsize , end='' )
#     return


	##
	# Example of implicit and explicit format.
	#validates :isbn, format: /\d{0,3}-?\d-\d{3}-\d+-\d/
	#validates :isbn, format: { with: /\d{0,3}-?\d-\d{3}-\d+-\d/, on: :create }

	validates :isbn, format: /\d{0,3}-?\d-\d{3,5}-\d+-[\dX]/, uniqueness: true, 
		allow_nil: true, allow_blank: true, message: ":: '%{value}'"

	# FIXME: What token should we allow? Ask chef!
	#
	#validates :bindung_bezeichnung, inclusion: { 
	#	in: %w(faden_hardcover klebe faden hardcover multi unknown), 
	#	message: "'%{value}' ist keine zulässige Bindung.", 
	#	allow_nil: true, allow_blank: true }

	#validates :papier_bezeichnung, inclusion: { 
	#	in: %w(Offset\ 80g Offset\ 90g Werkdruck\ 100g Werkdruck\ 90g\ blau Werkdruck\ 90g\ gelb),
	#	MAYBE: in: %w(o80 o90 w90 wg100),
	#	message: "'%{value}' is keine zulässige Papierbezeichnung.",	
	#	allow_nil: true, allow_blank: true }

	#validates :umschlag_bezeichnung, inclusion: { 
	#	in: %w(LaTeX InDesign Geliefert),
	#	message: "'%{value}' is keine Umschlag-Abteilung.",	
	#	allow_nil: true, allow_blank: true }
  #
	#validates :format_bezeichnung, format: /(^A[345]$)|(^\d+ ?x ?\d+$)|(^$)/,
	#	allow_nil: true, allow_blank: true

end                                                   
