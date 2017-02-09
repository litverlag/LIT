class Gprod < ApplicationRecord

  has_one :buch
  accepts_nested_attributes_for :buch

  belongs_to :lektor
  accepts_nested_attributes_for :lektor

  has_one :titelei
  has_one :preps
  has_one :umschlag
  has_one :druck
  has_one :binderei
  has_one :satz
  has_one :final
=begin
  belongs_to :autor
  accepts_nested_attributes_for :autor
=end
end
