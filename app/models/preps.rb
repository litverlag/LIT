##
# # /app/models/preps.rb
# Represents the Prepress department.
class Preps < Gprod
	#def self.default_scope
	#	Preps.joins("INNER JOIN status_preps on status_preps.gprod_id = gprods.id")\
	#	.where("status_preps.status IS NOT NULL")
	#end
  
  #status_names array must be written in the same order of the status_strings array (see models/concerns/global_variables) + table name + symbol for StatusOptionsAdapter
  scope_maker([:neu_filter, :bearbeitung_filter, :verschickt_filter, :fertig_filter, :problem_filter], "status_preps", StatusOptionsAdapter.option(:statuspreps)) 

end


