##
# app/models/Lektor.rb
# Represents a Lektor with his personal Information
class Lektor < ApplicationRecord
	self.table_name = 'lektoren'

  #has_one :admin_user
  #accepts_nested_attributes_for :admin_user

  has_many :gprod
  accepts_nested_attributes_for :gprod


 # ransacker :nameAndFoxName do |parent|
 #    Arel::Nodes::InfixOperation.new('||', Arel::Nodes::InfixOperation.new('||', parent.table[:name], Arel::Nodes.build_quoted(' ')),parent.table[:fox_name])
 #  end

  def fullname
    "#{self.name} #{self.fox_name}"
  end

	validates :name, uniqueness: true, allow_nil: true, allow_blank: false

 end
