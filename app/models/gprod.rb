class Gprod < ActiveRecord::Base

  has_one :buch
  accepts_nested_attributes_for :buch

  belongs_to :lektor
  accepts_nested_attributes_for :lektor

  belongs_to :autor
  accepts_nested_attributes_for :autor

  has_one :statusfinal
  accepts_nested_attributes_for :statusfinal
  has_one :statusdruck
  accepts_nested_attributes_for :statusdruck
  has_one :statustitelei
  accepts_nested_attributes_for :statustitelei
  has_one :statussatz
  accepts_nested_attributes_for :statussatz
  has_one :statuspreps
  accepts_nested_attributes_for :statuspreps
  has_one :statusoffsch
  accepts_nested_attributes_for :statusoffsch
  has_one :statusbildpr
  accepts_nested_attributes_for :statusbildpr
  has_one :statusumschlag
  accepts_nested_attributes_for :statusumschlag
  has_one :statusrg
  accepts_nested_attributes_for :statusrg
  has_one :statusbinderei
  accepts_nested_attributes_for :statusbinderei

end
