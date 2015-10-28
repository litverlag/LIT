class Buch < ActiveRecord::Base
  belongs_to :format
  belongs_to :bindung
  belongs_to :papier
  belongs_to :umschlag
  belongs_to :lektor

  has_and_belongs_to_many :reihen
  accepts_nested_attributes_for :reihen, :allow_destroy => true

  has_and_belongs_to_many :autoren
  accepts_nested_attributes_for :autoren, :allow_destroy => true

  belongs_to :gprod
  accepts_nested_attributes_for :gprod



  def short_isbn
    i = Lisbn.new("978-#{self.isbn}")

    if i.valid?
      "#{i.parts[3]}-#{i.parts[4]}"
    else
       self.isbn
    end
  end
end
