class Publication < ActiveRecord::Base
  belongs_to :buch
  belongs_to :autor
end
