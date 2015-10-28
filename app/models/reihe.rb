class Reihe < ActiveRecord::Base
  
	has_and_belongs_to_many :buecher
	accepts_nested_attributes_for :buecher, :allow_destroy => true

	has_and_belongs_to_many :autoren
	accepts_nested_attributes_for :autoren, :allow_destroy => true
end
