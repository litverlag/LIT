class Gprod < ActiveRecord::Base
  has_one :lektor
  accepts_nested_attributes_for :lektor

  has_one :autor
  accepts_nested_attributes_for :autor

  has_one :buch
  accepts_nested_attributes_for :buch

  def initialize(*args)
    super

    build_buch
    build_autor
    build_lektor
  end


end
