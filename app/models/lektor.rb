class Lektor < ActiveRecord::Base
  has_many :admin_users_lektoren
  has_many :admin_users, through: :admin_users_lektoren
  accepts_nested_attributes_for :admin_users, :allow_destroy => true
  accepts_nested_attributes_for :admin_users_lektoren, :allow_destroy => true

  belongs_to :gprods
  accepts_nested_attributes_for :gprods




 ransacker :nameAndFoxName do |parent|
    Arel::Nodes::InfixOperation.new('||', Arel::Nodes::InfixOperation.new('||', parent.table[:name], Arel::Nodes.build_quoted(' ')),parent.table[:fox_name])
  end

  def fullname
    "#{self.name} #{self.fox_name}"
  end

 end
