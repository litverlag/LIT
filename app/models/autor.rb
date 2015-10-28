class Autor < ActiveRecord::Base

  has_and_belongs_to_many :reihen
  accepts_nested_attributes_for :reihen, :allow_destroy => true

  has_and_belongs_to_many :buecher
  accepts_nested_attributes_for :buecher, :allow_destroy => true

  has_and_belongs_to_many :gprods
  accepts_nested_attributes_for :gprods


  ransacker :fullname do |parent|
    Arel::Nodes::InfixOperation.new('||', Arel::Nodes::InfixOperation.new('||', parent.table[:vorname], Arel::Nodes.build_quoted(' ')),parent.table[:name])
  end

  def fullname
    "#{self.anrede} #{self.vorname} #{self.name}"
  end
end
