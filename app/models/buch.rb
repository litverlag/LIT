class Buch < ActiveRecord::Base
  belongs_to :format
  belongs_to :bindung
  belongs_to :papier
  belongs_to :umschlag
  belongs_to :lektor

  has_many :reihen_zuordnungen
  has_many :reihen, through: :reihen_zuordnungen
  accepts_nested_attributes_for :reihen_zuordnungen, :allow_destroy => true

  has_many :autoren_buecher
  has_many :autoren, through: :autoren_buecher
  accepts_nested_attributes_for :autoren, :allow_destroy => true
  accepts_nested_attributes_for :autoren_buecher, :allow_destroy => true

  belongs_to :gprods
  accepts_nested_attributes_for :gprods



  def short_isbn
    i = Lisbn.new("978-#{self.isbn}")

    if i.valid?
      "#{i.parts[3]}-#{i.parts[4]}"
    else
       self.isbn
    end
  end
end
