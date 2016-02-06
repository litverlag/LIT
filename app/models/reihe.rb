class Reihe < ActiveRecord::Base
  
	has_and_belongs_to_many :buecher
	accepts_nested_attributes_for :buecher

	has_and_belongs_to_many :autoren
	accepts_nested_attributes_for :autoren
	 

end
