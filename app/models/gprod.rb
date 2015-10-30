class Gprod < ActiveRecord::Base

  has_one :buch
  accepts_nested_attributes_for :buch

  belongs_to :lektor
  accepts_nested_attributes_for :lektor

  belongs_to :autor
  accepts_nested_attributes_for :autor
end
