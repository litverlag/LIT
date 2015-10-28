class Reihe < ActiveRecord::Base
  
	has_and_belongs_to_many :buecher
	accepts_nested_attributes_for :buecher, :allow_destroy => true

	has_and_belongs_to_many :autoren
	accepts_nested_attributes_for :autoren, :allow_destroy => true
  #has_many :reihen_zuordnungen
  #has_many :buecher, through: :reihen_zuordnungen
  #has_many :reihen_hg_zuordnungen
  #has_many :autoren, through: :reihen_hg_zuordnungen
  #accepts_nested_attributes_for :autoren, :allow_destroy => true
  #accepts_nested_attributes_for :reihen_hg_zuordnungen, :allow_destroy => true
  #accepts_nested_attributes_for :reihen_zuordnungen, :allow_destroy => true
end
