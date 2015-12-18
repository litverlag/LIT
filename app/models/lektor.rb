class Lektor < ActiveRecord::Base

  has_one :admin_user
  accepts_nested_attributes_for :admin_user

  has_many :gprod
  accepts_nested_attributes_for :gprod


 ransacker :nameAndFoxName do |parent|
    Arel::Nodes::InfixOperation.new('||', Arel::Nodes::InfixOperation.new('||', parent.table[:name], Arel::Nodes.build_quoted(' ')),parent.table[:fox_name])
  end

  def fullname
    "#{self.name} #{self.fox_name}"
  end

 end
