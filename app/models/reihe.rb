class Reihe < ActiveRecord::Base
  
	has_and_belongs_to_many :buecher
	accepts_nested_attributes_for :buecher

	has_and_belongs_to_many :autoren
	accepts_nested_attributes_for :autoren

	# Used for some 'collection:' entry.
	def self.rcodes
		all_r_codes = []
		self.all.each{|r|
			all_r_codes.append(r.r_code)
		}
		all_r_codes.sort
	end

end
