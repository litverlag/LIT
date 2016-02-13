##
# # /app/models/autor.rb
# This model represents an author at LIT. It is normally a person from which the Lektor gets contacted.
# The model has several attributes so that the Author can them that they can later be exported to the address system
# of the LIT-Verlag.
class Autor < ActiveRecord::Base

  has_and_belongs_to_many :reihen
  accepts_nested_attributes_for :reihen

  has_and_belongs_to_many :buecher
  accepts_nested_attributes_for :buecher

  has_one :gprods
  accepts_nested_attributes_for :gprods

##
# Returns the title, surname and name of the author as one string.
  def fullname
    "#{self.anrede} #{self.vorname} #{self.name}"
  end

## This methods filters all the empty attributes from a params hash. It was Never in use
#   def self.associate_with(modelinstance,attributes)
#
#     keys_with_not_empty_entries = []
#     attributes.to_h.each do |key, value|
#       if not value.eql?("")
#         keys_with_not_empty_entries.append(key)
#       end
#     end
#
#     relevant_attr = attributes.to_h.slice(*keys_with_not_empty_entries)
#
#     if modelinstance.autor
#       #Autor.where(relevant_attr).to_a.first über das Array kann man auf das Model zugreifen welches in der DBRelation steht welche die .where() methode ausgibt
#       # if Autor.where(relevant_attr).nil?
#       #   modelinstance.autor = Autor.where(relevant_attr).first_or_create
#       # else
#         if modelinstance.autor = Autor.where(relevant_attr).to_a.first
#           modelinstance.save
#           return true
#         else
#           return false
#         end
#
#       end
#     end
 end
