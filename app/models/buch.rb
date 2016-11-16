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
	# Lets overwrite r_code assignment, so that we link the correspoding Reihe.
	def r_code=(rc)
		self[:r_code] = rc
		self.reihen = Reihe.where(r_code: rc)
	end

  ##
  # Checks if the ISBN is corrent makes use of the LISBN gem
	#
	## Who wrote this bullshit? How about we dont assume that the isbn data in
	##  the database is incomplete?
	## Fixed.
  def short_isbn
		i = Lisbn.new(isbn)					 if (/\d{3}-\d-\d{3}-\d+/ =~ isbn) == 0
		i = Lisbn.new("978-#{isbn}") if (			 /\d-\d{3}-\d+/ =~ isbn) == 0
		return nil if i.nil?
		if i.valid?
			"#{i.parts[3]}-#{i.parts[4]}"
		else
			"#WrongFormat: '#{isbn}'"
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
		return nil if gprod.externer_druck or seiten.nil? or seiten == 0 or not
				I18n.t('paper_names').values.include?(papier_bezeichnung)
		factor_table = {
			I18n.t('paper_names.offset80') => 0.05 ,
			I18n.t('paper_names.offset90') => 0.06 ,
			I18n.t('paper_names.werk90b') => 0.055,
			I18n.t('paper_names.werk90g') => 0.055 ,
			I18n.t('paper_names.werk100') => 0.06 ,
			'KunstdruckMatt'			=> 0.05 ,
		}
		factor = factor_table[papier_bezeichnung]
		return nil unless factor
		sz = seiten * factor
		##
		# What you see here are rules defined by the guy who print the books.
		#	- Always round up
		#	- If we would round up, but backsize is small(<15), we need to add 1
		if sz.round <= sz
			return sz.round + 1
		else 
			if sz < 15 and (sz.round - sz <= 0.2)
				return sz.round + 1
			else
				return sz.round
			end
		end
	end

	##
	# Example of implicit and explicit format.
	#validates :isbn, format: /\d{0,3}-?\d-\d{3}-\d+-\d/
	#validates :isbn, format: { with: /\d{0,3}-?\d-\d{3}-\d+-\d/, on: :create }

	validates :isbn, format: { 
		with: /\d{0,3}-?\d-\d{3,5}-\d+-[\dXx]/, 
		message: ":: '%{value}'"
	}, uniqueness: true, allow_nil: true, allow_blank: true

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
		#in: I18n.t('um_names').values,
		#message: "'%{value}' is keine Umschlag-Abteilung.",	
		#allow_nil: true, allow_blank: true }
	#
	#validates :format_bezeichnung, format: /(^A[345]$)|(^\d+ ?x ?\d+$)|(^$)/,
	#	allow_nil: true, allow_blank: true

end
