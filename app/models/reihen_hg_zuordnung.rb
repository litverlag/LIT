class ReihenHgZuordnung < ActiveRecord::Base
  belongs_to :reihe
  belongs_to :autor
end
