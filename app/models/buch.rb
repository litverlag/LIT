class Buch < ActiveRecord::Base
  belongs_to :format
  belongs_to :bindung
  belongs_to :papier
  belongs_to :umschlag
  has_many :publications
  has_many :autoren, through: :publications
  has_many :reihen_zuordnungen
  has_many :reihen, through: :reihen_zuordnungen
  accepts_nested_attributes_for :reihen_zuordnungen, :allow_destroy => true

  def short_isbn
    i = Lisbn.new("978-#{self.isbn}")

    if i.valid?
      "#{i.parts[3]}-#{i.parts[4]}"
    else
       self.isbn
    end
  end
end
