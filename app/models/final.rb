class Final < ApplicationRecord
  self.table_name = 'status_final'

  belongs_to :gprod
end
