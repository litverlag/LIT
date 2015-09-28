class ReihenZuordnung < ActiveRecord::Base
  belongs_to :reihe
  belongs_to :buch
end
