class Autor < ActiveRecord::Base

  has_and_belongs_to_many :reihen
  accepts_nested_attributes_for :reihen

  has_and_belongs_to_many :buecher
  accepts_nested_attributes_for :buecher

  has_and_belongs_to_many :gprods
  accepts_nested_attributes_for :gprods


  def fullname
    "#{self.anrede} #{self.vorname} #{self.name}"
  end



end
