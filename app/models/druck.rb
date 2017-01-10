##
# # /app/models/druck.rb
# Represents the departemnt Druckerei, sometimes referred as POD.
class Druck < Gprod
  
  def self.default_scope
    Druck.joins("INNER JOIN status_druck on status_druck.gprod_id = gprods.id")\
    .where("status_druck.status IS NOT NULL")
  end
  
  
#status_names array must be written in the same order of the status_strings array (see models/concerns/global_variables) + table name + symbol for StatusOptionsAdapter
  scope_maker([:musterdrucken, :nächsterAuftrag, :neu_filter, :bearbeitung_filter, :fertig_filter, :problem_filter], "status_druck", StatusOptionsAdapter.option(:statusdruck)) 

end
