class Gprod < ActiveRecord::Base
  #Mögliche Stati, die an childclasses von Gprod vererbt werden

  has_one :lektor
  accepts_nested_attributes_for :lektor

  has_one :autor
  accepts_nested_attributes_for :autor

  has_one :buch
  accepts_nested_attributes_for :buch



end
