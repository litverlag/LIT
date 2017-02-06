class Titelei < ApplicationRecord
  self.table_name = 'status_titelei'

  belongs_to :gprod
end
