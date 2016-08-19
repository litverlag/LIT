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
	# Validations. Hm. This is neat. VALIDATE ALL THE THINGS.
	# Example of short(implicit) and long(explicit) format.
	#validates :isbn, format: /\d{0,3}-?\d-\d{3}-\d+-\d/
	#validates :isbn, format: { with: /\d{0,3}-?\d-\d{3}-\d+-\d/, on: :create }

	validates :isbn, format: /\d{0,3}-?\d-\d{3}-\d+-\d/, uniqueness: true, 
		allow_nil: true, allow_blank: true
	validates :bindung_bezeichnung, inclusion: { 
		in: %w(faden_hardcover klebe faden hardcover multi unknown), 
		message: "'%{value}' ist keine zulässige Bindung.", 
		allow_nil: true, allow_blank: true }
	validates :papier_bezeichnung, inclusion: { 
		in: %w(Offset\ 80g Offset\ 90g Werkdruck\ 100g Werkdruck\ 90g\ blau Werkdruck\ 90g\ gelb),
		message: "'%{value}' is keine zulässige Papierbezeichnung.",	
		allow_nil: true, allow_blank: true }
	validates :umschlag_bezeichnung, inclusion: { 
		in: %w(LaTeX InDesign Geliefert),
		message: "'%{value}' is keine Umschlag-Abteilung.",	
		allow_nil: true, allow_blank: true }
	validates :format_bezeichnung, format: /(^A[345]$)|(^\d+ ?x ?\d+$)|(^$)/,
		allow_nil: true, allow_blank: true
end                                                   
