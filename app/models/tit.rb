##
# # /app/models/tit.rb
# Represents the part of the production process handled by the Titelei
class Tit < Gprod

  def self.default_scope
    Preps.joins("INNER JOIN status_preps on status_titelei.gprod_id = gprods.id")\
    .where("status_titelei.status IS NOT NULL")
  end
	
  #status_names array must be written in the same order of the status_strings array (see models/concerns/global_variables) + table name + symbol for StatusOptionsAdapter
  scope_maker([:neu_filter, :bearbeitung_filter, :verschickt_filter, :fertig_filter, :problem_filter], "status_titelei", StatusOptionsAdapter.option(:statustitelei))

	
end