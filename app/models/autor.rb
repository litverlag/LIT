class Autor < ActiveRecord::Base
  has_many :publications
  has_many :buecher, through: :publications
  has_many :reihen_hg_zuordnungen
  has_many :reihen, through: :reihen_hg_zuordnungen
  
  ransacker :fullname do |parent|
    Arel::Nodes::InfixOperation.new('||', Arel::Nodes::InfixOperation.new('||', parent.table[:vorname], Arel::Nodes.build_quoted(' ')),parent.table[:name])
  end

  def fullname
    "#{self.anrede} #{self.vorname} #{self.name}"
  end
end
