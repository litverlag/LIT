class Buch < ApplicationRecord
  self.table_name = 'buecher'

  belongs_to :gprod
end
