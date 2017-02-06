class Umschlag < ApplicationRecord
  self.table_name = 'status_umschl'

  belongs_to :gprod
end
