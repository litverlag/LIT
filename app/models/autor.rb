##
# # /app/models/autor.rb
# This model represents an author at LIT. It is normally a person from which the Lektor gets contacted.
# The model has several attributes so that the Author can them that they can later be exported to the address system
# of the LIT-Verlag.
class Autor < ActiveRecord::Base
	include ActiveModel::Validations

  has_and_belongs_to_many :reihen
  accepts_nested_attributes_for :reihen

  has_and_belongs_to_many :buecher
  accepts_nested_attributes_for :buecher

  has_one :gprod
  accepts_nested_attributes_for :gprod

##
# Returns the title, surname and name of the author as one string.
  def fullname
    "#{self.anrede} #{self.vorname} #{self.name}"
  end

	def select_string
		"#{name}, #{vorname} (#{anrede})"
	end

	##
	# Validations..
	validates :email, format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i, 
										allow_nil: true,
										allow_blank: true

 end
