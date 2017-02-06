class Druck < ApplicationRecord
  self.table_name = 'status_druck'

  belongs_to :gprod
end
