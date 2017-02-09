class Satz < ApplicationRecord
  self.table_name = 'status_satz'

  belongs_to :gprod
  belongs_to :bearbeiter, class_name: 'User'
end
