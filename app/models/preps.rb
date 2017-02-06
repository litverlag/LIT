class Preps < ApplicationRecord
  self.table_name = 'status_preps'

  belongs_to :gprod
end
