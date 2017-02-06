class Binderei < ApplicationRecord
  self.table_name = 'status_binderei'

  belongs_to :gprod
end
