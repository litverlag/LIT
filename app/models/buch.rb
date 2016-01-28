## The model for the Buch class
#
#
class Buch < ActiveRecord::Base

  has_and_belongs_to_many :reihen
  accepts_nested_attributes_for :reihen

  has_and_belongs_to_many :autoren
  accepts_nested_attributes_for :autoren

  belongs_to :gprod
  belongs_to :lektor

  has_one :format
  has_one :bindung
  has_one :papier
  has_one :umschlag
  accepts_nested_attributes_for :format, :bindung, :papier, :umschlag

  def short_isbn
    i = Lisbn.new("978-#{self.isbn}")

    if i.valid?
      "#{i.parts[3]}-#{i.parts[4]}"
    else
       self.isbn
    end
  end

  ##
  # all_attributes_set? checks if there is at least one nil attribute in the table.
  # Notice that here the field lektor_id and autor_id are hardcoded but you can remove them
  # if the entries are removed from the Database table
  def all_attributes_set?
    all_attri = true
    self.attributes.each do |key,value|
      next if key.eql?("lektor_id") | key.eql?("autor_id")
      if value.blank?
        all_attri = false
      end
    end
    return all_attri
  end




end
